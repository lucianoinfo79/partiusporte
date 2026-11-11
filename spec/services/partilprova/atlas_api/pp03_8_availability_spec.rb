require "rails_helper"

RSpec.describe Partilprova::AtlasApi::Availability do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  subject(:probe) { described_class.new(client: client) }

  it "checks the uncached public event endpoint" do
    response = Partilprova::AtlasApi::Response.new(status: 200, headers: {}, data: { "data" => [] }, raw_body: "")
    expect(client).to receive(:get).with("events", params: { page: 1, per_page: 1 }, headers: { "Cache-Control" => "no-cache" }).and_return(response)
    expect(probe.call.available?).to eq(true)
  end

  it "marks transport failure as unavailable without exposing details" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::TransportError.new("private host"))
    result = probe.call
    expect(result.state).to eq(:unavailable)
    expect(result.http_status).to be_nil
  end

  it "distinguishes an invalid upstream payload" do
    response = Partilprova::AtlasApi::Response.new(status: 200, headers: {}, data: "unexpected", raw_body: "")
    allow(client).to receive(:get).and_return(response)
    expect(probe.call.state).to eq(:invalid_response)
  end

  it "reports upstream HTTP failures without treating them as healthy" do
    response = Partilprova::AtlasApi::Response.new(status: 503, headers: {}, data: {}, raw_body: "")
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::HttpError.new(response))
    result = probe.call
    expect(result.available?).to eq(false)
    expect(result.http_status).to eq(503)
  end
end

RSpec.describe "PP03.8 discovery cache generation" do
  it "changes the discovery cache key when publication generation changes" do
    configuration = Partilprova::AtlasApi::Configuration.new(base_url: "https://atlas.example/api/public/v1")
    client = Partilprova::AtlasApi::Client.new(configuration: configuration)
    uri = configuration.uri_for("events")
    previous_enabled = ENV["PARTILPROVA_PUBLIC_CACHE_ENABLED"]
    previous_generation = ENV["PARTILPROVA_PUBLIC_CACHE_GENERATION"]
    begin
      ENV["PARTILPROVA_PUBLIC_CACHE_ENABLED"] = "true"
      ENV["PARTILPROVA_PUBLIC_CACHE_GENERATION"] = "release_1"
      first = client.send(:public_cache_key, "events", uri, {})
      ENV["PARTILPROVA_PUBLIC_CACHE_GENERATION"] = "release_2"
      second = client.send(:public_cache_key, "events", uri, {})
      expect(first).not_to eq(second)
      expect(client.send(:public_cache_key, "events/1/results", uri, {})).to be_nil
    ensure
      ENV["PARTILPROVA_PUBLIC_CACHE_ENABLED"] = previous_enabled
      ENV["PARTILPROVA_PUBLIC_CACHE_GENERATION"] = previous_generation
    end
  end
end
