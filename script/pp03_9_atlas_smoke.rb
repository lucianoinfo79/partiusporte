# Run inside PartilProva: bundle exec rails runner script/pp03_9_atlas_smoke.rb
# Read-only probe. Never prints response bodies or secrets.
require "uri"

base = ENV.fetch("ATLAS_PUBLIC_API_BASE_URL", "")
abort "PP03.9 FAIL: ATLAS_PUBLIC_API_BASE_URL not configured" if base.empty?
uri = URI.parse(base)
abort "PP03.9 FAIL: API URL must be HTTP(S)" unless %w[http https].include?(uri.scheme)

result = Partilprova::AtlasApi::Availability.new.call
puts "PP03.9 Atlas API: state=#{result.state} http_status=#{result.http_status || 'n/a'}"
abort "PP03.9 FAIL: Atlas API unavailable; investigate host authorization/network/contract" unless result.available?
puts "PP03.9 PASS: public events endpoint responds with a supported payload"
puts "PP03.9 NOTE: registration, results and photos require real published fixtures and manual verification"
