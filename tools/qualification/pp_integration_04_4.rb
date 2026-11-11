# frozen_string_literal: true
# PP-INTEGRATION.04.4 — read-only registration handoff diagnostic.
require "json"

slug = ENV.fetch("PP_EVENT_SLUG", "").strip
abort "PP_EVENT_SLUG is required" if slug.empty?

detail = Partilprova::PublicPortal::EventDetail.new.call(identifier: slug)
unless detail.available?
  warn JSON.pretty_generate({ slug: slug, detail_state: detail.state, passed: false })
  exit 1
end

event = detail.event
handoff = Partilprova::PublicPortal::RegistrationHandoff.new.call(event: event)
provider = event[:registration_provider].to_s
status = event[:registration_status].to_s
origin = ENV.fetch("PARTILPROVA_ATLAS_PUBLIC_ORIGIN", "")
hosts = ENV.fetch("PARTILPROVA_REGISTRATION_ALLOWED_HOSTS", "")
origin_host = begin
  URI.parse(origin).host
rescue URI::InvalidURIError
  nil
end

checks = {
  "event_available" => detail.available?,
  "registration_status_open" => %w[open opened active available].include?(status.downcase),
  "provider_supported" => %w[atlas external unavailable].include?(provider),
  "atlas_public_origin_configured" => provider != "atlas" || origin.present?,
  "atlas_public_origin_https" => provider != "atlas" || origin.start_with?("https://"),
  "atlas_origin_host_allowlisted" => provider != "atlas" || (origin_host.present? && hosts.split(",").map(&:strip).map(&:downcase).include?(origin_host.downcase)),
  "atlas_target_present" => provider != "atlas" || event[:registration_target].present?,
  "handoff_available" => handoff.available?
}
puts JSON.pretty_generate({
  slug: slug, provider: provider, status: status,
  handoff_state: handoff.state,
  atlas_public_origin_host: origin_host,
  configured_allowlist_hosts: hosts.split(",").map(&:strip).reject(&:empty?),
  registration_target_present: event[:registration_target].present?,
  checks: checks,
  passed: checks.values.all?
})
exit(checks.values.all? ? 0 : 1)
