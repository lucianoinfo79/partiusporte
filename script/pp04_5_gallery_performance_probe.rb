# Run with: bundle exec rails runner script/pp04_5_gallery_performance_probe.rb
# Read-only. Does not print signed preview URLs or tokens.
require "benchmark"
identifier = ARGV.first || "evento-oportunidade-teste"
samples = Integer(ENV.fetch("PP045_SAMPLES", "3"))
abort "PP045_SAMPLES must be 1..10" unless (1..10).cover?(samples)
client = Partilprova::AtlasApi::Client.new
puts "PP04.5 API latency probe: #{samples} samples, event=#{identifier.inspect}"
durations = []
samples.times do |i|
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  begin
    result = client.get("events/#{identifier}/photos", params: { page: 1, per_page: 24 }).data
    elapsed = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    count = result.is_a?(Hash) ? Array(result.dig("data", "photos")).size : 0
    durations << elapsed
    puts "sample=#{i + 1} status=ok duration_ms=#{elapsed} photos=#{count}"
  rescue Partilprova::AtlasApi::Error => error
    elapsed = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    puts "sample=#{i + 1} status=error duration_ms=#{elapsed} error=#{error.class.name}"
  end
end
if durations.any?
  ordered = durations.sort
  puts "summary min_ms=#{ordered.first} median_ms=#{ordered[ordered.size / 2]} max_ms=#{ordered.last}"
end
