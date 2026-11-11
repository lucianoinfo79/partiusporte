require "rails_helper"

RSpec.describe "PP05.2 — public bib search", type: :request do
  let(:catalog) do
    Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: :available, event: { "name" => "Corrida" }, photos: [],
      page: 1, total: 0, has_next: false, participant_url: nil
    )
  end

  before do
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(catalog)
  end

  it "keeps search unavailable until Atlas public filtering is explicitly enabled" do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", "false").and_return("false")
    get "/eventos/prova/fotos", params: { bib_number: "009001" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ainda não está disponível")
    expect(response.body).not_to include("Buscar fotos por número de peito")
  end

  it "passes only normalized bib and page to the catalog when enabled" do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", "false").and_return("true")
    expect_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call)
      .with(event_identifier: "prova", page: 2, bib_number: "009001").and_return(catalog)
    get "/eventos/prova/fotos", params: { bib_number: " 009001 ", page: "2" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Buscar fotos por número de peito")
  end

  it "rejects invalid public bib queries" do
    get "/eventos/prova/fotos", params: { bib_number: "1 OR 1=1" }
    expect(response).to have_http_status(:bad_request)
  end
end
