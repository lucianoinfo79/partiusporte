require "rails_helper"

RSpec.describe "PP05.4 gallery result states", type: :request do
  def result(state:, photos: [], total: 0)
    Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: state, event: { "name" => "Corrida" }, photos: photos,
      page: 1, total: total, has_next: false, participant_url: nil
    )
  end

  before do
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(result(state: :available))
  end

  it "shows an informative empty gallery without inventing results" do
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-pp05-4="empty"', "Ainda não há fotos disponíveis")
    expect(response.body).not_to include("master_url", "original_url")
  end

  it "shows a count and keeps the protected viewer" do
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(
      result(state: :available, total: 1, photos: [
        { id: "123e4567-e89b-12d3-a456-426614174000", preview_url: "/preview", photographer: "Equipe", captured_at: nil, participant_url: nil }
      ])
    )
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("1 fotografia no catálogo", 'data-controller="photo-gallery"')
  end

  it "distinguishes unpublished from temporarily unavailable" do
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(result(state: :unpublished))
    get "/eventos/prova/fotos"
    expect(response.body).to include('data-pp05-4="unpublished"', "Fotos ainda não publicadas")

    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(result(state: :unavailable))
    get "/eventos/prova/fotos"
    expect(response.body).to include('data-pp05-4="unavailable"', "Tentar novamente")
  end

  it "retains native GET form behavior when the search capability is enabled" do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", "false").and_return("true")
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-controller="gallery-submit"', 'method="get"')
  end
end
