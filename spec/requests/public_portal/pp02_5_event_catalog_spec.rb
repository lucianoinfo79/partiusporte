require "rails_helper"

RSpec.describe "PP02.5 public event catalog", type: :request do
  let(:catalog) { Partilprova::PublicPortal::EventCatalog }
  let(:filters) { { q: "", modality: "", state: "", city: "", status: "", order: "date_asc", from: nil, to: nil } }

  it "renders the catalog and filters" do
    allow_any_instance_of(catalog).to receive(:call).and_return(
      catalog::Result.new(events: [], available: true, filters: filters, page: 1, per_page: 12, total: 0, has_next: false, modalities: catalog::MODALITIES)
    )
    get "/eventos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Encontre sua próxima prova", "Nenhum evento encontrado", "Filtrar eventos")
  end

  it "keeps the catalog available when Atlas is offline" do
    allow_any_instance_of(catalog).to receive(:call).and_return(
      catalog::Result.new(events: [], available: false, filters: filters, page: 1, per_page: 12, total: 0, has_next: false, modalities: catalog::MODALITIES)
    )
    get "/eventos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Agenda temporariamente indisponível")
  end
end
