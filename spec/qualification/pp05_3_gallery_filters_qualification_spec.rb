require "rails_helper"

RSpec.describe "PP05.3 public gallery filters", type: :request do
  let(:catalog) do
    Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: :available,
      event: { "name" => "Corrida", "photo_filter_options" => {
        "albums" => [{ "id" => "a1", "name" => "Largada" }],
        "sessions" => [{ "id" => "s1", "name" => "Manhã" }] } },
      photos: [], page: 2, total: 0, has_next: false, participant_url: nil
    )
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(catalog)
  end

  it "does not expose filters before the Atlas contract is enabled" do
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false").and_return("false")
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("Aplicar filtros")
    get "/eventos/prova/fotos", params: { album_id: "a1" }
    expect(response).to have_http_status(:bad_request)
  end

  it "renders public choices and forwards selected filters only to the server" do
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false").and_return("true")
    expect_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).with(
      event_identifier: "prova", page: 2, bib_number: nil, album_id: "a1", session_id: "s1"
    ).and_return(catalog)
    get "/eventos/prova/fotos", params: { page: "2", album_id: "a1", session_id: "s1" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Aplicar filtros", "Largada", "Manhã")
  end
end
