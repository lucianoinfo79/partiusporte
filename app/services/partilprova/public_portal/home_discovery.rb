module Partilprova
  module PublicPortal
    class HomeDiscovery
      Result = Data.define(:events, :modalities, :available, :query, :modality)

      DEFAULT_MODALITIES = [
        ["Todos", "all"], ["Corrida de Rua", "running"], ["Ciclismo", "cycling"],
        ["Mountain Bike", "mtb"], ["Triathlon", "triathlon"],
        ["Caminhada", "walking"], ["Outros", "other"]
      ].freeze

      def initialize(client: Partilprova::AtlasApi::Client.new)
        @client = client
      end

      def call(query: nil, modality: nil)
        params = request_params(query, modality)
        filtered = query.present? || (modality.present? && modality != "all")

        # Search and modality filters must include non-featured published events.
        response = client.get("events", params: filtered ? params.except(:featured) : params)
        events = normalize_events(response.data)

        # On the unfiltered Home, prefer highlights but fall back to the catalog.
        if events.empty? && !filtered
          response = client.get("events", params: { limit: 8 })
          events = normalize_events(response.data)
        end
        Result.new(events: events, modalities: DEFAULT_MODALITIES,
                   available: true, query: query.to_s, modality: modality.to_s)
      rescue Partilprova::AtlasApi::Error
        Result.new(events: [], modalities: DEFAULT_MODALITIES, available: false,
                   query: query.to_s, modality: modality.to_s)
      end

      private

      attr_reader :client

      def request_params(query, modality)
        { q: query.presence, modality: modality.presence == "all" ? nil : modality.presence,
          featured: true, limit: 8 }
      end

      def normalize_events(payload)
        collection = payload.is_a?(Hash) ? (payload["events"] || payload["data"] || []) : payload
        Array(collection).filter_map { |item| normalize_event(item) if item.is_a?(Hash) }
      end

      def normalize_event(item)
        starts_at = parse_time(item["starts_at"] || item["start_at"] || item["date"])
        {
          id: item["id"], slug: item["slug"], name: item["name"] || item["title"] || "Evento esportivo",
          city: item["city"] || item.dig("location", "city"),
          state: item["state"] || item["state_code"] || item.dig("location", "state"),
          modality: item["modality_name"] || item["modality"] || "Evento esportivo",
          starts_at: starts_at,
          registration_status: item["registration_status"] || item["status"],
          image_url: item["cover_url"] || item["image_url"]
        }
      end

      def parse_time(value)
        Time.zone.parse(value.to_s) if value.present?
      rescue ArgumentError, TypeError
        nil
      end
    end
  end
end
