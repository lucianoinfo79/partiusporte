require "uri"

module Partilprova
  module PublicPortal
    class PhotoCatalog
      PER_PAGE = 24
      MAX_PAGE = 1_000
      Result = Data.define(:state, :event, :photos, :page, :total, :has_next, :participant_url) do
        def available? = state == :available
        def not_found? = state == :not_found
        def unpublished? = state == :unpublished
      end

      def initialize(client: Partilprova::AtlasApi::Client.new)
        @client = client
      end

      def call(event_identifier:, page: nil, bib_number: nil, album_id: nil, session_id: nil)
        current_page = [[page.to_i, 1].max, MAX_PAGE].min
        params = { page: current_page, per_page: PER_PAGE }
        params[:bib_number] = bib_number if bib_number.present?
        params[:album_id] = album_id if album_id.present?
        params[:session_id] = session_id if session_id.present?
        response = @client.get("events/#{event_identifier}/photos", params: params).data
        data = response.is_a?(Hash) ? response["data"] : nil
        return fallback(:unavailable, current_page) unless data.is_a?(Hash)

        event = data["event"].is_a?(Hash) ? data["event"].dup : {}
        # Public Atlas metadata is optional. Never derive choices from private photo identifications.
        event["photo_filter_options"] = data["filters"] if data["filters"].is_a?(Hash)
        return fallback(:unpublished, current_page, event: event) if data["published"] == false || data["status"] == "unpublished"

        raw = data["photos"] || data["data"] || []
        return fallback(:unavailable, current_page) unless raw.is_a?(Array)

        photos = raw.first(PER_PAGE).filter_map do |photo|
          next unless photo.is_a?(Hash)
          preview = safe_preview_url(photo["preview_url"] || photo["thumbnail_url"], event_identifier: event_identifier, photo_id: photo["id"])
          next unless preview
          {
            id: photo["id"],
            preview_url: preview,
            photographer: photo["photographer_name"].to_s.first(100),
            captured_at: photo["captured_at"],
            participant_url: allowed_participant_url(photo["participant_url"])
          }
        end

        meta = response["meta"].is_a?(Hash) ? response["meta"] : {}
        total = (meta["total"] || data["total"]).to_i
        has_next = meta["has_next"] == true || (total.positive? ? current_page * PER_PAGE < total : raw.length == PER_PAGE)
        Result.new(state: :available, event: event, photos: photos, page: current_page,
          total: total, has_next: has_next,
          participant_url: allowed_participant_url(data["participant_url"]))
      rescue Partilprova::AtlasApi::HttpError => error
        fallback(error.response.status == 404 ? :not_found : :unavailable, current_page)
      rescue Partilprova::AtlasApi::Error
        fallback(:unavailable, current_page)
      end

      private

      def fallback(state, page, event: {})
        Result.new(state: state, event: event, photos: [], page: page,
          total: 0, has_next: false, participant_url: nil)
      end

      # Production: only HTTPS previews. Development: HTTP Atlas previews are
      # represented as same-origin paths; no upstream token reaches the browser.
      def safe_preview_url(value, event_identifier:, photo_id:)
        uri = URI.parse(value.to_s)
        return uri.to_s if uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil?
        return unless Rails.env.development? && ENV["PP0431_LOCAL_PREVIEW_PROXY"] == "true"
        return unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.nil?
        expected = Partilprova::AtlasApi::Configuration.new.uri_for("events/#{event_identifier}/photos")
        return unless uri.scheme == expected.scheme && uri.host == expected.host && uri.port == expected.port
        return unless photo_id.to_s.match?(/\A[0-9a-fA-F-]{36}\z/)
        expected_path = "#{expected.path}/#{photo_id}/preview"
        return unless uri.path == expected_path
        Rails.application.routes.url_helpers.local_public_event_photo_preview_path(id: event_identifier, photo_id: photo_id)
      rescue URI::InvalidURIError, ArgumentError
        nil
      end

      def safe_https_url(value)
        uri = URI.parse(value.to_s)
        return unless uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil?
        uri.to_s
      rescue URI::InvalidURIError
        nil
      end

      def allowed_participant_url(value)
        uri = URI.parse(value.to_s)
        return unless uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil?
        allowed = ENV.fetch("PARTILPROVA_PARTICIPANT_ALLOWED_HOSTS", "").split(",").map(&:strip).reject(&:blank?)
        uri.to_s if allowed.any? { |host| uri.host.casecmp?(host) }
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
