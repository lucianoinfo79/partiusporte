require "rails_helper"
RSpec.describe Partilprova::PublicPortal::EventDetail do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  subject(:service) { described_class.new(client: client) }

  it "fetches a single event and normalizes the public fields" do
    allow(client).to receive(:get).with("events/corrida-do-parque").and_return(
      double(data: { "event" => { "name" => "Corrida do Parque", "city" => "Palmas", "distances" => ["5 km", "10 km"] } })
    )
    result = service.call(identifier: "corrida-do-parque")
    expect(result.available?).to be(true)
    expect(result.event[:distances]).to eq(["5 km", "10 km"])
  end

  it "handles Atlas transport errors without raising" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::TransportError, "offline")
    expect(service.call(identifier: "1").state).to eq(:unavailable)
  end

  it "distinguishes not found from unavailable" do
    response = double(status: 404)
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::HttpError.new(response))
    expect(service.call(identifier: "missing").not_found?).to be(true)
  end

  it "does not accept javascript links" do
    allow(client).to receive(:get).and_return(double(data: { "name" => "Prova", "registration_url" => "javascript:alert(1)" }))
    expect(service.call(identifier: "1").event[:registration_url]).to be_nil
  end
end
