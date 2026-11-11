require "rails_helper"

RSpec.describe "PP02.11 Atlas API resilience" do
  RawAtlasResponse = Struct.new(:code, :body, :headers) do
    def each_header
      return enum_for(:each_header) unless block_given?
      headers.each { |key, value| yield(key, value) }
    end
  end
  class SequencedAtlasTransport
    attr_reader :calls
    def initialize(*results)
      @results = results
      @calls = 0
    end
    def get(**_args)
      result = @results.fetch(@calls)
      @calls += 1
      raise result if result.is_a?(Exception)
      result
    end
  end

  let(:configuration) { Partilprova::AtlasApi::Configuration.new(base_url: "https://atlas.example/api/public/v1") }
  let(:ok) { RawAtlasResponse.new("200", '{"events":[]}', {}) }

  it "retries one transient upstream 503" do
    transport = SequencedAtlasTransport.new(RawAtlasResponse.new("503", "{}", {}), ok)
    client = Partilprova::AtlasApi::Client.new(configuration: configuration, transport: transport)
    expect(client.get("events").data).to eq("events" => [])
    expect(transport.calls).to eq(2)
  end

  it "does not retry 404" do
    transport = SequencedAtlasTransport.new(RawAtlasResponse.new("404", "{}", {}))
    client = Partilprova::AtlasApi::Client.new(configuration: configuration, transport: transport)
    expect { client.get("events/missing") }.to raise_error(Partilprova::AtlasApi::HttpError)
    expect(transport.calls).to eq(1)
  end

  it "caches only public event discovery without custom headers when enabled" do
    cache = ActiveSupport::Cache::MemoryStore.new
    transport = SequencedAtlasTransport.new(ok, ok)
    client = Partilprova::AtlasApi::Client.new(configuration: configuration, transport: transport, cache: cache)
    previous = ENV["PARTILPROVA_PUBLIC_CACHE_ENABLED"]
    ENV["PARTILPROVA_PUBLIC_CACHE_ENABLED"] = "true"
    begin
      expect(client.get("events", params: { state: "TO" }).data).to eq("events" => [])
      expect(client.get("events", params: { state: "TO" }).data).to eq("events" => [])
      expect(transport.calls).to eq(1)
      client.get("events", params: { state: "TO" }, headers: { "X-Request-ID" => "x" })
      expect(transport.calls).to eq(2)
    ensure
      ENV["PARTILPROVA_PUBLIC_CACHE_ENABLED"] = previous
    end
  end
end
