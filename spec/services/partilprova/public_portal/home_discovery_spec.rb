require "rails_helper"

RSpec.describe Partilprova::PublicPortal::HomeDiscovery do
  Response = Struct.new(:data)
  FakeClient = Struct.new(:response) do
    attr_reader :last_path, :last_params
    def get(path, params: {})
      self.last_path = path; self.last_params = params; response
    end
    private
    attr_writer :last_path, :last_params
  end

  it "loads and normalizes filtered events from the Atlas public boundary" do
    client = FakeClient.new(Response.new({"events" => [{"id" => 7, "name" => "Corrida do Parque", "city" => "Palmas", "state" => "TO", "modality" => "Corrida de Rua", "date" => "2026-10-15T07:00:00-03:00"}]}))
    result = described_class.new(client: client).call(query: "parque", modality: "running")
    expect(client.last_path).to eq("events")
    expect(client.last_params).to include(q: "parque", modality: "running", limit: 8)
    expect(client.last_params).not_to have_key(:featured)
    expect(result.events.first).to include(name: "Corrida do Parque", city: "Palmas", state: "TO")
    expect(result.available).to be(true)
  end

  it "degrades safely when Atlas is unavailable" do
    client = Object.new
    def client.get(*) = raise(Partilprova::AtlasApi::TransportError, "offline")
    result = described_class.new(client: client).call
    expect(result.events).to eq([])
    expect(result.available).to be(false)
  end
end


RSpec.describe "PP-INTEGRATION.03.1 Home ↔ Catalog consistency" do
  it "falls back to published events when no featured events exist" do
    client = double("atlas_client")
    expect(client).to receive(:get).with("events", params: hash_including(featured: true)).ordered
      .and_return(Response.new({"events" => []}))
    expect(client).to receive(:get).with("events", params: { limit: 8 }).ordered
      .and_return(Response.new({"events" => [{"id" => "natalina", "name" => "3ª MARATONA NATALINA 2026"}]}))
    result = Partilprova::PublicPortal::HomeDiscovery.new(client: client).call
    expect(result.events.map { |event| event[:name] }).to include("3ª MARATONA NATALINA 2026")
  end

  it "does not restrict a text search to featured events" do
    client = double("atlas_client")
    expect(client).to receive(:get).once.with("events", params: { q: "Natalina", modality: nil, limit: 8 })
      .and_return(Response.new({"events" => [{"id" => 1, "name" => "Natalina"}]}))
    result = Partilprova::PublicPortal::HomeDiscovery.new(client: client).call(query: "Natalina")
    expect(result.events.first[:name]).to eq("Natalina")
  end

  it "queries all published events when a modality filter is selected" do
    client = double("atlas_client")
    expect(client).to receive(:get).once
      .with("events", params: { q: nil, modality: "cycling", limit: 8 })
      .and_return(Response.new({"events" => [{"id" => 2, "name" => "Pedal do Lago"}]}))
    result = Partilprova::PublicPortal::HomeDiscovery.new(client: client).call(modality: "cycling")
    expect(result.events.first[:name]).to eq("Pedal do Lago")
  end

  it "treats the all modality as unfiltered and falls back when highlights are empty" do
    client = double("atlas_client")
    expect(client).to receive(:get).with("events", params: { q: nil, modality: nil, featured: true, limit: 8 }).ordered
      .and_return(Response.new({"events" => []}))
    expect(client).to receive(:get).with("events", params: { limit: 8 }).ordered
      .and_return(Response.new({"events" => [{"id" => 3, "name" => "Corrida Aberta"}]}))
    result = Partilprova::PublicPortal::HomeDiscovery.new(client: client).call(modality: "all")
    expect(result.events.first[:name]).to eq("Corrida Aberta")
  end
end
