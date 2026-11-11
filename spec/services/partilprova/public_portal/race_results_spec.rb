require "rails_helper"

RSpec.describe Partilprova::PublicPortal::RaceResults do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:service) { described_class.new(client: client) }

  it "retrieves published classification with pagination" do
    payload = { "event" => { "name" => "Corrida do Parque" }, "published" => true,
      "results" => [{ "position" => 1, "bib_number" => "123", "athlete_name" => "Ana",
                       "net_time" => "00:24:30" }], "meta" => { "total" => 31 } }
    expect(client).to receive(:get).with("events/prova/results",
      params: { page: 1, per_page: 30 }).and_return(double(data: payload))
    result = service.call(event_identifier: "prova")
    expect(result.available?).to eq(true)
    expect(result.rows.first[:bib]).to eq("123")
    expect(result.has_next).to eq(true)
  end

  it "does not silently ignore filters unsupported by Atlas v1" do
    expect(client).not_to receive(:get)
    result = service.call(event_identifier: "prova", q: "Ana", category: "F30")
    expect(result.state).to eq(:filters_unsupported)
    expect(result.rows).to be_empty
  end

  it "does not expose unpublished classifications" do
    allow(client).to receive(:get).and_return(double(data: { "published" => false, "results" => [{ "name" => "Privado" }] }))
    result = service.call(event_identifier: "prova")
    expect(result.unpublished?).to eq(true)
    expect(result.rows).to be_empty
  end

  it "treats Atlas outages as unavailable" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::TransportError, "offline")
    expect(service.call(event_identifier: "prova").state).to eq(:unavailable)
  end

  it "distinguishes a missing result resource" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::HttpError.new(double(status: 404)))
    expect(service.call(event_identifier: "prova").not_found?).to eq(true)
  end
end
