require "rails_helper"

RSpec.describe "PP02.4 Home / Descobrir Provas", type: :request do
  let(:result) do
    Partilprova::PublicPortal::HomeDiscovery::Result.new(
      events: [{ id: 1, slug: "corrida-do-parque", name: "Corrida do Parque", city: "Palmas", state: "TO", modality: "Corrida de Rua", starts_at: Time.zone.parse("2026-10-15 07:00"), registration_status: "open", image_url: nil }],
      modalities: Partilprova::PublicPortal::HomeDiscovery::DEFAULT_MODALITIES,
      available: true, query: "", modality: ""
    )
  end

  before do
    allow_any_instance_of(Partilprova::PublicPortal::HomeDiscovery).to receive(:call).and_return(result)
  end

  it "renders the approved participant-facing discovery home" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-pp02-4="home-discovery"', "Encontre seu próximo", "Próximos eventos", "Corrida do Parque", "Palmas")
  end

  it "keeps search and modality discovery public" do
    get root_path, params: { q: "parque", modality: "running" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Busque por evento, cidade ou modalidade", "Corrida de Rua", "Mountain Bike")
  end
end
