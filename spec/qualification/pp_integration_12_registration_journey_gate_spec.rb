# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PP-INTEGRATION.12 PartilProva to Atlas journey gate", type: :request do
  let(:event_data) do
    {
      name: "Corrida Atlas 2026", city: "Palmas", state: "TO", date: "2026-12-01",
      description: "Jornada pública de inscrição", distances: [], routes: [], schedule: [],
      kit: "", organizer: "MGL", venue: "Parque", modality: "Corrida",
      registration_status: "open", registration_provider: "atlas",
      registration_target: "/events/atlas-run/editions/atlas-2026/register",
      image_url: nil, registration_url: nil, regulation_url: nil,
      results_url: nil, photos_url: nil
    }
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch)
      .with("PARTILPROVA_REGISTRATION_ALLOWED_HOSTS", "")
      .and_return("atlas.example,registration.example")
    allow(ENV).to receive(:fetch)
      .with("PARTILPROVA_ATLAS_PUBLIC_ORIGIN", "")
      .and_return("https://atlas.example")

    result = Partilprova::PublicPortal::EventDetail::Result.new(event: event_data, state: :available)
    allow_any_instance_of(Partilprova::PublicPortal::EventDetail).to receive(:call).and_return(result)
  end

  it "hands Atlas registrations to the trusted Atlas route in the same tab" do
    get "/eventos/corrida-atlas-2026"

    expect(response).to have_http_status(:ok)
    cta = Nokogiri::HTML(response.body).at_css('a[data-pp-registration-handoff="atlas"]')
    expect(cta).to be_present
    expect(cta["href"]).to eq("https://atlas.example/events/atlas-run/editions/atlas-2026/register")
    expect(cta["target"]).to be_nil
    expect(response.body).to include("Você continuará sua inscrição no ambiente oficial do Atlas.")
  end

  it "keeps external registration destinations in a separate tab" do
    event_data[:registration_provider] = "external"
    event_data[:registration_target] = "https://registration.example/race/42"

    get "/eventos/corrida-atlas-2026"

    expect(response).to have_http_status(:ok)
    cta = Nokogiri::HTML(response.body).at_css('a[data-pp-registration-handoff="external"]')
    expect(cta).to be_present
    expect(cta["href"]).to eq("https://registration.example/race/42")
    expect(cta["target"]).to eq("_blank")
    expect(cta["rel"]).to eq("noopener noreferrer")
  end

  it "keeps the Atlas CTA unavailable when Atlas reports registrations closed" do
    event_data[:registration_status] = "unavailable"

    get "/eventos/corrida-atlas-2026"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Inscrições não disponíveis pelo PartilProva para esta prova.")
    expect(response.body).not_to include("Inscreva-se agora")
  end
end
