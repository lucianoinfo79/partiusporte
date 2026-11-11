# frozen_string_literal: true
# PP-INTEGRATION.04.4.2 — read-only event detail diagnostic
require "json"
require "uri"

slug = ENV.fetch("PP_EVENT_SLUG", "").strip
abort "PP_EVENT_SLUG is required" if slug.empty?

result = { slug: slug, rails_environment: Rails.env }

begin
  client = Partilprova::AtlasApi::Client.new
  path = "events/#{URI.encode_www_form_component(slug)}"
  response = client.get(path)
  payload = response.data
  record = payload.is_a?(Hash) ? (payload["event"] || payload["data"] || payload) : nil
  result[:api_status] = response.status
  result[:api_payload_type] = payload.class.name
  result[:event_record_type] = record.class.name
  if record.is_a?(Hash)
    result[:api_event_name] = record["name"] || record["title"]
    result[:api_publication_status] = record["publication_status"]
    result[:api_published] = record["published"]
    result[:api_publicly_visible] = record["publicly_visible"]
    result[:visibility_accepted] = Partilprova::PublicPortal::PublicationVisibility.visible?(record)
    result[:registration_status] = record.dig("registration", "status") if record["registration"].is_a?(Hash)
    result[:registration_provider] = record.dig("registration", "provider") if record["registration"].is_a?(Hash)
  end
rescue Partilprova::AtlasApi::HttpError => error
  result[:api_status] = error.response.status
  result[:api_error] = "http_error"
rescue Partilprova::AtlasApi::Error => error
  result[:api_error] = error.class.name
end

begin
  detail = Partilprova::PublicPortal::EventDetail.new.call(identifier: slug)
  result[:detail_state] = detail.state
  if detail.available?
    result[:normalized_name] = detail.event[:name]
    handoff = Partilprova::PublicPortal::RegistrationHandoff.new.call(event: detail.event)
    result[:handoff_state] = handoff.state
    result[:handoff_url_present] = handoff.url.present?
  end
rescue StandardError => error
  result[:detail_exception] = error.class.name
end

result[:conclusion] =
  if result[:api_status] == 404
    "Atlas API returned HTTP 404: verify published slug and API base configuration"
  elsif result[:api_error]
    "Atlas API request failed: check container network and API configuration"
  elsif result[:visibility_accepted] == false
    "PartilProva publication visibility rejected the Atlas event payload"
  elsif result[:detail_state] == :available
    "Event detail is available; investigate registration handoff separately"
  else
    "Detail lookup differs from direct API read; inspect response shape and request configuration"
  end

puts JSON.pretty_generate(result)
exit(result[:detail_state] == :available ? 0 : 1)
