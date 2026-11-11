require "rails_helper"

RSpec.describe Partilprova::AtlasApi::Client do
  FakeRawResponse = Struct.new(:code, :body, :headers) do
    def each_header
      return enum_for(:each_header) unless block_given?
      headers.each { |key, value| yield key, value }
    end
  end

  class FakeAtlasTransport
    attr_reader :requests

    def initialize(response)
      @response = response
      @requests = []
    end

    def get(**request)
      requests << request
      @response
    end
  end

  let(:configuration) do
    Partilprova::AtlasApi::Configuration.new(
      base_url: "https://atlas.example/api/public/v1",
      open_timeout: 2,
      read_timeout: 5
    )
  end

  it "performs a GET using the configured Atlas public boundary" do
    transport = FakeAtlasTransport.new(FakeRawResponse.new("200", '{"events":[]}', { "x-request-id" => "atlas-123" }))
    client = described_class.new(configuration: configuration, transport: transport)

    response = client.get("events", params: { state: "TO", modality: ["run", "mtb"], empty: nil })
    request = transport.requests.fetch(0)

    expect(request[:uri].to_s).to eq("https://atlas.example/api/public/v1/events?state=TO&modality=run&modality=mtb")
    expect(request[:headers]).to include("Accept" => "application/json")
    expect(request[:open_timeout]).to eq(2)
    expect(request[:read_timeout]).to eq(5)
    expect(response.data).to eq("events" => [])
    expect(response.request_id).to eq("atlas-123")
  end

  it "allows request headers without mutating the default headers" do
    transport = FakeAtlasTransport.new(FakeRawResponse.new("200", "{}", {}))
    client = described_class.new(configuration: configuration, transport: transport)

    client.get("events/42", headers: { "X-Request-ID" => "partilprova-42" })

    expect(transport.requests.first[:headers]).to include(
      "Accept" => "application/json",
      "X-Request-ID" => "partilprova-42"
    )
  end

  it "raises a typed HTTP error and keeps the Atlas response available" do
    transport = FakeAtlasTransport.new(FakeRawResponse.new("404", '{"error":"not_found"}', {}))
    client = described_class.new(configuration: configuration, transport: transport)

    expect { client.get("events/missing") }.to raise_error(Partilprova::AtlasApi::HttpError) { |error|
      expect(error.response.status).to eq(404)
      expect(error.response.data).to eq("error" => "not_found")
    }
  end

  it "rejects malformed JSON responses explicitly" do
    transport = FakeAtlasTransport.new(FakeRawResponse.new("200", "<html>failure</html>", {}))
    client = described_class.new(configuration: configuration, transport: transport)

    expect { client.get("events") }.to raise_error(Partilprova::AtlasApi::InvalidResponseError, /invalid JSON/)
  end

  it "accepts an empty successful response body" do
    transport = FakeAtlasTransport.new(FakeRawResponse.new("204", "", {}))
    client = described_class.new(configuration: configuration, transport: transport)

    response = client.get("health")

    expect(response).to be_success
    expect(response.data).to be_nil
  end
end
