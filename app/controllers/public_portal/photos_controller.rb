module PublicPortal
  class PhotosController < BaseController
    # Development-only, explicitly opted-in, same-origin preview bridge.
    # The requested photo must still be present in Atlas's current public gallery.
    def local_preview
      return head :not_found unless Rails.env.development? && ENV["PP0431_LOCAL_PREVIEW_PROXY"] == "true"

      photo_id = params[:photo_id].to_s
      return head :not_found unless photo_id.match?(/\A[0-9a-fA-F-]{36}\z/)

      event_identifier = params[:id].to_s
      return head :not_found unless event_identifier.match?(/\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,127}\z/)

      config = Partilprova::AtlasApi::Configuration.new
      base = config.uri_for("events/#{event_identifier}/photos")
      return head :not_found unless base.scheme == "http"

      require "net/http"
      require "json"
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      gallery_response = Net::HTTP.start(base.host, base.port, use_ssl: false,
        open_timeout: config.open_timeout, read_timeout: config.read_timeout) do |http|
        http.get(base.request_uri, { "Accept" => "application/json" })
      end
      return head :not_found unless gallery_response.code == "200"
      payload = JSON.parse(gallery_response.body)
      return head :not_found unless payload.dig("data", "published") == true
      photo = Array(payload.dig("data", "photos")).find { |item| item.is_a?(Hash) && item["id"] == photo_id }
      return head :not_found unless photo

      uri = URI.parse(photo["preview_url"].to_s)
      expected_path = "#{base.path}/#{photo_id}/preview"
      return head :not_found unless uri.is_a?(URI::HTTP) && uri.host == base.host &&
        uri.port == base.port && uri.userinfo.nil? && uri.path == expected_path && uri.query.present?

      upstream_response = Net::HTTP.start(uri.host, uri.port, use_ssl: false,
        open_timeout: config.open_timeout, read_timeout: config.read_timeout) do |http|
        http.get(uri.request_uri, { "Accept" => "image/jpeg" })
      end
      return head :not_found unless upstream_response.code == "200" &&
        upstream_response["content-type"].to_s.split(";").first == "image/jpeg" &&
        upstream_response.body.bytesize.between?(1, 5.megabytes)

      Rails.logger.info({
        component: "pp04_5_photo_preview",
        outcome: "success",
        duration_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round,
        bytes: upstream_response.body.bytesize
      }.to_json)
      self.response.headers["Cache-Control"] = "private, no-store"
      self.response.headers["X-Content-Type-Options"] = "nosniff"
      send_data upstream_response.body, type: "image/jpeg", disposition: "inline"
      self.response.headers["Cache-Control"] = "private, no-store"
    rescue JSON::ParserError, URI::InvalidURIError, ArgumentError, IOError,
      Timeout::Error, SocketError, SystemCallError
      head :not_found
    end

    def index; end

    def show
      @photo_search_capability = Partilprova::PublicPortal::PhotoSearchCapability.current
      @photo_search_query = Partilprova::PublicPortal::PhotoSearchContract.build(
        event_identifier: params[:id], bib_number: params[:bib_number], page: params[:page]
      )
      @photo_search_bib = @photo_search_query.bib_number
      if @photo_search_query.filtered? && !@photo_search_capability.available?
        @photo_search_unavailable = true
        @photo_search_bib = nil
        @photo_search_query = Partilprova::PublicPortal::PhotoSearchContract.build(event_identifier: params[:id])
      end
      @gallery_filters_enabled = Partilprova::PublicPortal::PhotoGalleryFilterContract.enabled?
      @gallery_filters = Partilprova::PublicPortal::PhotoGalleryFilterContract.build(
        album_id: params[:album_id], session_id: params[:session_id], enabled: @gallery_filters_enabled
      )
      @catalog = Partilprova::PublicPortal::PhotoCatalog.new.call(
        event_identifier: @photo_search_query.event_identifier,
        page: @photo_search_query.page,
        bib_number: @photo_search_query.filtered? ? @photo_search_query.bib_number : nil,
        **@gallery_filters.public_params
      )
      @gallery_filter_options = Partilprova::PublicPortal::PhotoGalleryFilterContract.options(@catalog.event)
      render status: :not_found if @catalog.not_found?
    rescue Partilprova::PublicPortal::PhotoSearchContract::InvalidQuery,
      Partilprova::PublicPortal::PhotoGalleryFilterContract::InvalidQuery
      head :bad_request
    end
  end
end
