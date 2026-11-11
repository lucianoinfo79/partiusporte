# frozen_string_literal: true

require "time"

module Partilprova
  module PublicPortal
    class EventCalendar
      Result = Data.define(
        :month, :selected_date, :days, :events, :selected_events, :events_by_date,
        :cities, :modalities, :statuses, :filters, :available
      )

      MODALITIES = [
        ["Todas as modalidades", "all"], ["Corrida de Rua", "running"],
        ["Ciclismo", "cycling"], ["Mountain Bike", "mtb"], ["Triathlon", "triathlon"],
        ["Caminhada", "walking"], ["Outros", "other"]
      ].freeze
      STATUSES = [
        ["Todos os eventos", "all"], ["Inscrições abertas", "open"],
        ["Em breve", "scheduled"], ["Inscrições encerradas", "closed"]
      ].freeze
      STATUS_LABELS = {
        "open" => "Inscrições abertas", "scheduled" => "Em breve",
        "closed" => "Inscrições encerradas", "unavailable" => "A confirmar"
      }.freeze
      RUNNING_MODALITIES = %w[running half_marathon kids trail].freeze

      def initialize(client: Partilprova::AtlasApi::Client.new)
        @client = client
      end

      def call(month: nil, date: nil, modality: nil, city: nil, status: nil)
        selected_month = parse_month(month)
        filters = {
          modality: normalize_filter(modality, MODALITIES.map(&:last)),
          city: city.to_s.strip.first(100),
          status: normalize_filter(status, STATUSES.map(&:last))
        }
        api_response = client.get("events", params: {
          from: selected_month.beginning_of_month.iso8601,
          to: selected_month.end_of_month.iso8601,
          per_page: 100
        })
        month_events = normalize_events(api_response.data)
        cities = month_events.map { |event| event[:city] }.compact_blank
        cities << filters[:city] if filters[:city].present?
        cities = cities.uniq.sort
        filtered_events = filter_events(month_events, filters)
        events_by_date = filtered_events.group_by { |event| event[:starts_at].to_date }
        selected_date = parse_selected_date(date, selected_month, events_by_date.keys)
        Result.new(
          month: selected_month,
          selected_date: selected_date,
          days: calendar_days(selected_month),
          events: filtered_events,
          selected_events: events_by_date.fetch(selected_date, []),
          events_by_date: events_by_date,
          cities: cities,
          modalities: MODALITIES,
          statuses: STATUSES,
          filters: filters,
          available: true
        )
      rescue Partilprova::AtlasApi::Error
        selected_month ||= parse_month(month)
        selected_date = parse_selected_date(date, selected_month, [])
        Result.new(
          month: selected_month,
          selected_date: selected_date,
          days: calendar_days(selected_month),
          events: [], selected_events: [], events_by_date: {}, cities: [],
          modalities: MODALITIES, statuses: STATUSES, filters: filters || {}, available: false
        )
      end

      private

      attr_reader :client

      def parse_month(value)
        Date.strptime(value.to_s, "%Y-%m").beginning_of_month
      rescue Date::Error, ArgumentError
        Date.current.beginning_of_month
      end

      def parse_selected_date(value, month, event_dates)
        candidate = Date.iso8601(value.to_s) if value.present?
        return candidate if candidate && candidate.year == month.year && candidate.month == month.month

        event_dates.min || month
      rescue Date::Error
        event_dates.min || month
      end

      def calendar_days(month)
        first = month.beginning_of_month.beginning_of_week(:monday)
        last = month.end_of_month.end_of_week(:monday)
        (first..last).to_a
      end

      def normalize_filter(value, allowed)
        candidate = value.to_s.strip
        allowed.include?(candidate) ? candidate : "all"
      end

      def normalize_events(payload)
        collection = payload.is_a?(Hash) ? (payload["events"] || payload["data"] || []) : payload
        collection = collection["items"] || [] if collection.is_a?(Hash)
        Array(collection).filter_map { |item| normalize_event(item) if item.is_a?(Hash) }
      end

      def normalize_event(item)
        starts_at = parse_time(item["starts_at"], item["timezone"])
        return unless starts_at

        location = item["location"].to_h
        registration = item["registration"].to_h
        modalities = Array(item["modalities"]).filter_map do |entry|
          data = entry.to_h
          { code: data["code"].to_s, name: data["name"].to_s, course_type: data["course_type"].to_s }
        end
        {
          id: item["id"], slug: item["slug"],
          name: item["name"].presence || "Evento esportivo",
          starts_at: starts_at,
          city: item["city"].presence || location["city"],
          state: item["state"].presence || location["state"],
          image_url: item["cover_url"].presence || item["image_url"],
          modalities: modalities,
          modality_label: modality_label(modalities.first),
          registration_status: registration["status"].presence || item["registration_status"] || item["status"],
          registration_status_label: STATUS_LABELS[registration["status"].presence || item["registration_status"] || item["status"]]
        }
      rescue ArgumentError, TypeError
        nil
      end

      def parse_time(value, timezone)
        return if value.blank?

        parsed = Time.iso8601(value.to_s)
        parsed.in_time_zone(Time.find_zone(timezone.presence) || Time.zone)
      rescue ArgumentError, TypeError, TZInfo::InvalidTimezoneIdentifier
        Time.zone.parse(value.to_s)
      end

      def filter_events(events, filters)
        events.select do |event|
          matches_modality?(event, filters[:modality]) &&
            (filters[:city].blank? || event[:city].to_s.casecmp?(filters[:city])) &&
            matches_status?(event[:registration_status], filters[:status])
        end
      end

      def matches_modality?(event, filter)
        return true if filter.blank? || filter == "all"

        event[:modalities].any? do |race|
          case filter
          when "running" then RUNNING_MODALITIES.include?(race[:code])
          when "cycling" then race[:code] == "cycling" && race[:course_type] != "trail"
          when "mtb" then race[:code] == "cycling" && race[:course_type] == "trail"
          else race[:code] == filter
          end
        end
      end

      def matches_status?(event_status, filter)
        return true if filter.blank? || filter == "all"

        event_status.to_s == filter
      end

      def modality_label(race)
        return "Evento esportivo" unless race
        return "Mountain Bike" if race[:code] == "cycling" && race[:course_type] == "trail"

        race[:name].presence || "Evento esportivo"
      end
    end
  end
end
