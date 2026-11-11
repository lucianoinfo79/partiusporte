require "rails_helper"

RSpec.describe "PP05.5 protected viewer integration", type: :request do
  let(:photo) do
    { id: "123e4567-e89b-12d3-a456-426614174000",
      preview_url: "/eventos/prova/fotos/123e4567-e89b-12d3-a456-426614174000/preview",
      photographer: "Equipe", captured_at: nil, participant_url: nil }
  end

  before do
    result = Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: :available, event: { "name" => "Corrida" }, photos: [photo],
      page: 2, total: 30, has_next: true, participant_url: nil
    )
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(result)
  end

  it "keeps the protected viewer scoped to the current page and preserves navigation context" do
    get "/eventos/prova/fotos", params: { page: 2 }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-pp05-5="protected-viewer"')
    expect(response.body).to include("Resultados da página 2", "Ampliar fotografia 1")
    expect(response.body).to include('data-photo-gallery-target="previous"', 'data-photo-gallery-target="next"')
    expect(response.body).to include(photo[:preview_url])
    expect(response.body).not_to include("original_url", "master_url", "download_url")
  end

  it "keeps the viewer within filtered results without exposing private metadata" do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch)
      .with("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false")
      .and_return("true")

    get "/eventos/prova/fotos", params: { page: 2, album_id: "album-1" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-pp05-5="protected-viewer"')
    expect(response.body).to include("Resultados da página 2", "filtros aplicados")
    expect(response.body).not_to include("original_url", "master_url", "download_url")
  end
end
