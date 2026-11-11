require "rails_helper"

RSpec.describe "PP05.6 — Gallery regression gate", type: :request do
  let(:photo_id) { "123e4567-e89b-12d3-a456-426614174000" }
  let(:preview) { "/eventos/prova/fotos/#{photo_id}/preview" }

  def result(state: :available, photos: [], page: 1, total: 0, has_next: false, event: { "name" => "Corrida" })
    Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: state, event: event, photos: photos, page: page,
      total: total, has_next: has_next, participant_url: nil
    )
  end

  def stub_result(value)
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(value)
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
  end

  it "keeps bib and gallery filters disabled until Atlas qualification" do
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", "false").and_return("false")
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false").and_return("false")
    stub_result(result)
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("Buscar fotos por número de peito", "Aplicar filtros")
    get "/eventos/prova/fotos", params: { album_id: "a1" }
    expect(response).to have_http_status(:bad_request)
  end

  it "rejects malformed public search input" do
    stub_result(result)
    get "/eventos/prova/fotos", params: { bib_number: "1 OR 1=1" }
    expect(response).to have_http_status(:bad_request)
    get "/eventos/prova/fotos", params: { page: "1001" }
    expect(response).to have_http_status(:bad_request)
  end

  it "passes normalized bib and selected album/session filters to the server" do
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", "false").and_return("true")
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false").and_return("true")
    expect_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).with(
      event_identifier: "prova", page: 2, bib_number: "009001", album_id: "a1", session_id: "s1"
    ).and_return(result(page: 2))
    get "/eventos/prova/fotos", params: { bib_number: " 009001 ", album_id: "a1", session_id: "s1", page: "2" }
    expect(response).to have_http_status(:ok)
  end

  it "keeps the viewer on the current result page without leaking private URLs" do
    stub_result(result(page: 2, total: 25, has_next: true, photos: [
      { id: photo_id, preview_url: preview, photographer: "Equipe", captured_at: nil, participant_url: nil }
    ]))
    get "/eventos/prova/fotos", params: { page: "2" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-pp05-5="protected-viewer"', "Resultados da página 2", preview)
    expect(response.body).not_to include("master_url", "original_url", "download_url")
  end

  it "distinguishes empty, unpublished and unavailable gallery states" do
    { available: 'data-pp05-4="empty"', unpublished: 'data-pp05-4="unpublished"',
      unavailable: 'data-pp05-4="unavailable"' }.each do |state, marker|
      stub_result(result(state: state))
      get "/eventos/prova/fotos"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(marker)
    end
  end

  it "returns not found for a missing event catalog" do
    stub_result(result(state: :not_found))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:not_found)
  end
end
