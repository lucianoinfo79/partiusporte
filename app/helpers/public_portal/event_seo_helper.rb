module PublicPortal
  module EventSeoHelper
    def pp_event_json_ld(event)
      return unless pp_seo_canonical
      name = event[:name].to_s.strip
      return if name.blank?
      data = {
        "@context" => "https://schema.org",
        "@type" => "SportsEvent",
        "name" => name,
        "url" => pp_seo_canonical
      }
      date = event[:date].to_s
      data["startDate"] = date if date.match?(/\\A\\d{4}-\\d{2}-\\d{2}/)
      description = event[:description].to_s.strip
      data["description"] = description.first(300) if description.present?
      data["image"] = event[:image_url] if event[:image_url].present?
      city = event[:city].to_s.strip
      state = event[:state].to_s.strip
      if city.present? || state.present?
        data["location"] = {
          "@type" => "Place",
          "name" => event[:venue].presence || [city, state].reject(&:blank?).join(" / "),
          "address" => {
            "@type" => "PostalAddress",
            "addressLocality" => city,
            "addressRegion" => state,
            "addressCountry" => "BR"
          }
        }
      end
      data.to_json
    end
  end
end
