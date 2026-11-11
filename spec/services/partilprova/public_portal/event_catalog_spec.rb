require "rails_helper"

RSpec.describe Partilprova::PublicPortal::EventCatalog do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:service) { described_class.new(client: client) }

  it "queries the Atlas events endpoint with filters and pagination" do
    response = double(data: { "events" => [{ "id" => 7, "name" => "Corrida do Parque", "city" => "Palmas" }], "meta" => { "total" => 13 } })
    expect(client).to receive(:get).with("events", params: hash_including(q: "Parque", state: "TO", page: 1, per_page: 12)).and_return(response)
    result = service.call(query: "Parque", state: "to")
    expect(result.events.first[:name]).to eq("Corrida do Parque")
    expect(result.has_next).to eq(true)
  end

  it "does not expose an exception when Atlas is unavailable" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::TransportError, "offline")
    result = service.call
    expect(result.available).to eq(false)
    expect(result.events).to be_empty
  end

  it "rejects invalid date filters before calling Atlas" do
    allow(client).to receive(:get).and_return(double(data: []))
    result = service.call(from: "invalid", to: "2026-10-15")
    expect(result.filters[:from]).to be_nil
    expect(result.filters[:to]).to eq("2026-10-15")
  end
end
