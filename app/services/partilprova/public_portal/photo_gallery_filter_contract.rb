module Partilprova
  module PublicPortal
    # PP05.3: only event-scoped public album/session identifiers; never identities or storage keys.
    # Atlas must implement AND filtering and provide public choices before enabling this flag.
    class PhotoGalleryFilterContract
      MAX_IDENTIFIER_LENGTH = 80
      Query = Data.define(:album_id, :session_id) do
        def filtered? = album_id.present? || session_id.present?
        def public_params
          {}.tap do |params|
            params[:album_id] = album_id if album_id.present?
            params[:session_id] = session_id if session_id.present?
          end
        end
      end
      class InvalidQuery < ArgumentError; end

      def self.enabled?
        ENV.fetch("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false") == "true"
      end

      def self.build(album_id: nil, session_id: nil, enabled: enabled?)
        album = normalize(album_id)
        session = normalize(session_id)
        raise InvalidQuery, "gallery filters unavailable" if !enabled && (album || session)
        Query.new(album_id: album, session_id: session)
      end

      # Atlas public response: data.filters.albums/sessions = [{id: "...", name: "..."}].
      # Only validated public labels/IDs may become dropdown options.
      def self.options(event)
        filters = event.is_a?(Hash) ? event["photo_filter_options"] : nil
        return { albums: [], sessions: [] } unless filters.is_a?(Hash)
        { albums: normalize_options(filters["albums"]), sessions: normalize_options(filters["sessions"]) }
      end

      def self.normalize(value)
        return nil if value.nil? || value == ""
        raise InvalidQuery, "invalid gallery filter" unless value.is_a?(String) &&
          value.length.between?(1, MAX_IDENTIFIER_LENGTH) &&
          value.match?(/\A[a-zA-Z0-9][a-zA-Z0-9_-]*\z/)
        value
      end
      private_class_method :normalize

      def self.normalize_options(items)
        return [] unless items.is_a?(Array)
        items.first(100).filter_map do |item|
          next unless item.is_a?(Hash)
          id = normalize(item["id"])
          label = item["name"]
          next unless id && label.is_a?(String) && label.strip.length.between?(1, 100)
          [label.strip, id]
        rescue InvalidQuery
          nil
        end.uniq { |label, id| id }
      end
      private_class_method :normalize_options
    end
  end
end
