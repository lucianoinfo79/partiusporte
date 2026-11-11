module Partilprova
  module PublicPortal
    class RaceResults
      PER_PAGE = 30
      MAX_PAGE = 1000
      Result = Data.define(:state, :event, :rows, :categories, :page, :has_next, :total, :filters) do
        def available? = state == :available
        def not_found? = state == :not_found
        def unpublished? = state == :unpublished
      end

      def initialize(client: Partilprova::AtlasApi::Client.new)
        @client = client
      end

      def call(event_identifier:, q: nil, category: nil, page: nil)
        current_page = [[page.to_i, 1].max, MAX_PAGE].min
        filters = { q: q.to_s.strip.first(100), category: category.to_s.strip.first(80) }
        # Atlas v1 currently supports pagination only; q/category are not applied by its query.
        # Never present an unfiltered response as if a requested filter had been applied.
        return result(:filters_unsupported, filters, current_page) if filters.values.any?(&:present?)

        data = @client.get("events/#{event_identifier}/results", params: { page: current_page, per_page: PER_PAGE }).data
        return result(:unavailable, filters, current_page) unless data.is_a?(Hash)

        event = data["event"].is_a?(Hash) ? data["event"] : {}
        published = data["published"] != false && data["status"] != "unpublished"
        return result(:unpublished, filters, current_page, event: event) unless published

        raw = data["results"] || data["rows"] || data["data"]
        return result(:unavailable, filters, current_page) unless raw.is_a?(Array)

        rows = raw.first(PER_PAGE).filter_map { |row| normalize(row) if row.is_a?(Hash) }
        meta = data["meta"].is_a?(Hash) ? data["meta"] : {}
        total = (meta["total"] || data["total"]).to_i
        has_next = if meta.key?("has_next")
          meta["has_next"] == true
        elsif total.positive?
          current_page * PER_PAGE < total
        else
          rows.length == PER_PAGE
        end
        Result.new(state: :available, event: event, rows: rows,
                   categories: safe_categories(data["categories"]), page: current_page,
                   has_next: has_next, total: total, filters: filters)
      rescue Partilprova::AtlasApi::HttpError => e
        result(e.response.status == 404 ? :not_found : :unavailable, filters, current_page)
      rescue Partilprova::AtlasApi::Error
        result(:unavailable, filters, current_page)
      end

      private

      def result(state, filters, page, event: {})
        Result.new(state: state, event: event, rows: [], categories: [], page: page,
                   has_next: false, total: 0, filters: filters)
      end

      def safe_categories(value)
        Array(value).select { |item| item.is_a?(String) }.first(100)
      end

      def format_seconds(value)
        return nil if value.nil?
        seconds = Integer(value, exception: false)
        return nil unless seconds && seconds >= 0
        hours, remaining = seconds.divmod(3600)
        minutes, secs = remaining.divmod(60)
        format("%02d:%02d:%02d", hours, minutes, secs)
      end

      def normalize(raw)
        {
          position: raw["position"] || raw["rank"],
          bib: raw["bib_number"] || raw["bib"],
          name: raw["athlete_name"] || raw["name"] || "Atleta",
          category: raw["category_name"] || raw["category"],
          time: raw["net_time"] || raw["chip_time"] || raw["time"] || format_seconds(raw["net_seconds"]),
          gross_time: raw["gross_time"] || format_seconds(raw["gross_seconds"]),
          status: raw["status"]
        }
      end
    end
  end
end
