module Partilprova
  module PublicPortal
    class EventCatalog
      PAGE_SIZE = 12
      MAX_PAGE = 10_000
      MODALITIES = HomeDiscovery::DEFAULT_MODALITIES
      ORDERS = %w[date_asc date_desc].freeze
      Result = Data.define(:events, :available, :filters, :page, :per_page, :total, :has_next, :modalities)

      def initialize(client: Partilprova::AtlasApi::Client.new)
        @client = client
      end

      def call(query: nil, modality: nil, state: nil, city: nil, status: nil, order: nil, page: nil, from: nil, to: nil)
        current_page = [[page.to_i, 1].max, MAX_PAGE].min
        filters = {
          q: query.to_s.strip.first(120),
          modality: modality.to_s == "all" ? "" : modality.to_s.first(40),
          state: state.to_s.strip.first(2).upcase,
          city: city.to_s.strip.first(100),
          status: status.to_s.first(40),
          order: ORDERS.include?(order) ? order : "date_asc",
          from: valid_date(from),
          to: valid_date(to)
        }
        response = @client.get("events", params: filters.merge(page: current_page, per_page: PAGE_SIZE).compact_blank)
        payload = response.data
        collection = payload.is_a?(Hash) ? (payload["events"] || payload["data"] || []) : payload
        collection = collection["items"] || [] if collection.is_a?(Hash)
        events = Array(collection).filter_map do |event|
          normalize(event) if Partilprova::PublicPortal::PublicationVisibility.visible?(event)
        end
        meta = payload.is_a?(Hash) ? (payload["meta"] || payload["pagination"] || {}) : {}
        total = (meta["total"] || payload_total(payload)).to_i
        has_next = if meta.key?("has_next")
          meta["has_next"] == true
        elsif total.positive?
          current_page * PAGE_SIZE < total
        else
          Array(collection).length == PAGE_SIZE
        end
        Result.new(events: events, available: true, filters: filters, page: current_page,
                   per_page: PAGE_SIZE, total: total, has_next: has_next, modalities: MODALITIES)
      rescue Partilprova::AtlasApi::Error
        Result.new(events: [], available: false, filters: filters, page: current_page,
                   per_page: PAGE_SIZE, total: 0, has_next: false, modalities: MODALITIES)
      end

      private

      def valid_date(value)
        return nil if value.blank?
        Date.iso8601(value.to_s).iso8601
      rescue Date::Error
        nil
      end

      def payload_total(payload)
        payload.is_a?(Hash) ? payload["total"] : nil
      end

      def normalize(item)
        date = item["starts_at"] || item["start_at"] || item["date"]
        starts_at = Time.zone.parse(date.to_s) if date.present?
        {
          id: item["id"], slug: item["slug"],
          name: item["name"] || item["title"] || "Evento esportivo",
          city: item["city"] || item.dig("location", "city"),
          state: item["state"] || item["state_code"] || item.dig("location", "state"),
          modality: item["modality_name"] || item["modality"] || "Evento esportivo",
          starts_at: starts_at,
          registration_status: item["registration_status"],
          image_url: item["cover_url"] || item["image_url"]
        }
      rescue ArgumentError, TypeError
        nil
      end
    end
  end
end
