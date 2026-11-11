module Partilprova
  module PublicPortal
    class EventDetail
      Result = Data.define(:event, :state) do
        def available? = state == :available
        def not_found? = state == :not_found
      end

      def initialize(client: Partilprova::AtlasApi::Client.new)
        @client = client
      end

      def call(identifier:)
        response = @client.get("events/#{URI.encode_www_form_component(identifier.to_s)}")
        raw = response.data
        raw = raw["event"] || raw["data"] || raw if raw.is_a?(Hash)
        return Result.new(event: nil, state: :unavailable) unless raw.is_a?(Hash)
        return Result.new(event: nil, state: :not_found) unless PublicationVisibility.visible?(raw)
        Result.new(event: normalize(raw), state: :available)
      rescue Partilprova::AtlasApi::HttpError => error
        Result.new(event: nil, state: error.response.status == 404 ? :not_found : :unavailable)
      rescue Partilprova::AtlasApi::Error
        Result.new(event: nil, state: :unavailable)
      end

      private

      def normalize(raw)
        location = raw["location"].is_a?(Hash) ? raw["location"] : {}
        registration = raw["registration"].is_a?(Hash) ? raw["registration"] : {}
        results = raw["results"].is_a?(Hash) ? raw["results"] : {}
        photos = raw["photos"].is_a?(Hash) ? raw["photos"] : {}
        {
          name: raw["name"] || raw["title"] || "Evento esportivo",
          description: raw["description"].to_s,
          date: raw["starts_at"] || raw["start_at"] || raw["date"],
          city: raw["city"] || location["city"],
          state: raw["state"] || location["state"],
          venue: raw["venue"] || location["venue"] || location["name"],
          modality: raw["modality_name"] || raw["modality"],
          registration_status: raw["registration_status"] || registration["status"],
          registration_provider: registration["provider"],
          registration_opens_at: registration["opens_at"],
          registration_closes_at: registration["closes_at"],
          registration_target: registration["target"],
          results_available: results["available"],
          photos_available: photos["available"],
          image_url: safe_image(raw["cover_url"] || raw["image_url"]),
          distances: safe_array(raw["distances"]),
          schedule: safe_array(raw["schedule"]),
          routes: safe_routes(raw["routes"]),
          supporters: safe_supporters(raw["supporters"]),
          kit: raw["kit_description"].to_s,
          regulation_url: safe_url(raw["regulation_url"]),
          registration_url: safe_url(raw["registration_url"] || registration["url"] || (registration["target"] if registration["provider"] == "external")),
          results_url: safe_url(raw["results_url"]),
          photos_url: safe_url(raw["photos_url"]),
          organizer: raw["organizer_name"].to_s
        }
      end

      def safe_array(value)
        value.is_a?(Array) ? value.first(30) : []
      end

      def safe_routes(value)
        safe_array(value).filter_map do |item|
          next item unless item.is_a?(Hash)

          route = item.stringify_keys
          geometry = route["geometry"].is_a?(Hash) ? route["geometry"].stringify_keys : {}
          coords = geometry["coordinates"].is_a?(Array) ? geometry["coordinates"].first(1_200) : []
          public_coords = coords.filter_map do |point|
            next unless point.is_a?(Array) && point.length >= 2

            lon, lat = Float(point[0]), Float(point[1])
            next unless lon.finite? && lat.finite? && lon.between?(-180, 180) && lat.between?(-90, 90)

            [lon, lat]
          rescue ArgumentError, TypeError
            nil
          end
          {
            "name" => route["name"].to_s.first(180),
            "race_name" => route["race_name"].to_s.first(180),
            "distance" => route["distance"].to_s.first(40),
            "description" => route["description"].to_s.first(2_000),
            "modality" => route["modality"].to_s.first(80),
            "geometry" => public_coords.length >= 2 ? { "type" => "LineString", "coordinates" => public_coords } : nil,
            "route_distance_km" => safe_number(route["route_distance_km"]),
            "elevation_gain_m" => safe_number(route["elevation_gain_m"]),
            "gpx_url" => safe_url(route["gpx_url"])
          }
        end
      end

      def safe_supporters(value)
        safe_array(value).filter_map do |item|
          next unless item.is_a?(Hash)

          supporter = item.stringify_keys
          name = supporter["name"].to_s.first(120)
          next if name.blank?

          {
            "name" => name,
            "tier" => supporter["tier"].to_s.first(60),
            "website_url" => safe_url(supporter["website_url"]),
            "logo_url" => safe_image(supporter["logo_url"])
          }
        end
      end

      def safe_number(value)
        number = Float(value)
        number if number.finite? && number >= 0
      rescue ArgumentError, TypeError
        nil
      end

      def safe_url(value)
        uri = URI.parse(value.to_s)
        uri.to_s if uri.is_a?(URI::HTTPS) || uri.is_a?(URI::HTTP)
      rescue URI::InvalidURIError
        nil
      end

      alias safe_image safe_url
    end
  end
end
