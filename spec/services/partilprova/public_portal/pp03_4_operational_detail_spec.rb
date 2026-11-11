require "rails_helper"

RSpec.describe Partilprova::PublicPortal::EventDetail do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  subject(:service) { described_class.new(client: client) }

  it "maps the Atlas v1 data envelope, nested location and registration" do
    allow(client).to receive(:get).with("events/corrida-2026").and_return(double(data: {
      "data" => {
        "slug" => "corrida-2026", "name" => "Corrida 2026", "starts_at" => "2026-11-01T07:00:00-03:00",
        "location" => { "city" => "Palmas", "state" => "TO", "venue" => "Praça Central" },
        "registration" => { "status" => "closed", "provider" => "atlas", "target" => "/events/1/editions/2/register" },
        "results" => { "available" => true }, "photos" => { "available" => false }
      }
    }))
    result = service.call(identifier: "corrida-2026")
    expect(result).to be_available
    expect(result.event).to include(city: "Palmas", state: "TO", venue: "Praça Central",
                                    registration_status: "closed", registration_provider: "atlas",
                                    results_available: true, photos_available: false, registration_url: nil)
  end

  it "rejects explicitly hidden detail records" do
    allow(client).to receive(:get).and_return(double(data: { "data" => { "name" => "Privado", "publication_status" => "hidden" } }))
    expect(service.call(identifier: "privado")).to be_not_found
  end

  it "does not promote an unsafe external target to a registration link" do
    allow(client).to receive(:get).and_return(double(data: { "data" => {
      "name" => "Corrida", "registration" => { "provider" => "external", "status" => "open", "target" => "javascript:alert(1)" }
    } }))
    expect(service.call(identifier: "corrida").event[:registration_url]).to be_nil
  end

  it "keeps external HTTPS targets for the existing handoff allowlist to verify" do
    allow(client).to receive(:get).and_return(double(data: { "data" => {
      "name" => "Corrida", "registration" => { "provider" => "external", "status" => "open", "target" => "https://inscricoes.exemplo.com/prova" }
    } }))
    expect(service.call(identifier: "corrida").event[:registration_url]).to eq("https://inscricoes.exemplo.com/prova")
  end
end
