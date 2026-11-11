require "rails_helper"

RSpec.describe "PP02.2 Public Shell", type: :request do
  before do
    allow_any_instance_of(Partilprova::PublicPortal::HomeDiscovery).to receive(:call).and_return(
      Partilprova::PublicPortal::HomeDiscovery::Result.new(events: [], modalities: Partilprova::PublicPortal::HomeDiscovery::DEFAULT_MODALITIES, available: true, query: "", modality: "")
    )
  end

  it "renders the approved public navigation around the current public home" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Eventos", "Calendário", "Resultados", "Fotos", "Sobre", "Contato")
    expect(response.body).to include('data-public-shell="header"')
  end

  it "keeps the participant-facing shell public" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("PartilProva")
  end
end
