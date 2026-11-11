require "rails_helper"

RSpec.describe Partilprova::PublicPortal::EventDetail, "PP-INTEGRATION.03.3" do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }

  it "projects the Atlas registration contract and event location" do
    allow(client).to receive(:get).and_return(double(data: {
      "event" => {
        "name" => "Maratona Natalina",
        "starts_at" => "2026-12-17T07:00:00-03:00",
        "location" => { "city" => "Palmas", "state" => "TO", "venue" => "Praia da Graciosa" },
        "registration" => { "status" => "open", "provider" => "external",
                            "target" => "https://organizador.example/inscricao",
                            "opens_at" => "2026-10-01T00:00:00-03:00" }
      }
    }))
    event = described_class.new(client: client).call(identifier: "maratona").event
    expect(event).to include(registration_status: "open", registration_provider: "external",
      registration_target: "https://organizador.example/inscricao",
      registration_opens_at: "2026-10-01T00:00:00-03:00",
      venue: "Praia da Graciosa")
  end
end
