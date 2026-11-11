require "rails_helper"

RSpec.describe "PP04.5 — Gallery qualification", type: :request do
  let(:photo_id) { "123e4567-e89b-12d3-a456-426614174000" }
  let(:preview) { "/eventos/prova/fotos/#{photo_id}/preview" }

  def catalog(state:, photos: [], page: 1, total: 0, has_next: false)
    Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: state, event: { "name" => "Corrida do Parque" },
      photos: photos, page: page, total: total, has_next: has_next, participant_url: nil
    )
  end

  def stub_catalog(result)
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog)
      .to receive(:call).and_return(result)
  end

  it "renders protected preview and the accessible viewer" do
    stub_catalog(catalog(state: :available, photos: [{
      id: photo_id, preview_url: preview, photographer: "Equipe",
      captured_at: nil, participant_url: nil
    }], total: 1))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(preview, "Ampliar fotografia 1", "Equipe")
    expect(response.body).to include('data-photo-gallery-target="dialog"')
    expect(response.body).not_to include("original_url", "master_url")
  end

  it "shows the unpublished state without rendering previews" do
    stub_catalog(catalog(state: :unpublished))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Fotos ainda não publicadas")
    expect(response.body).to include('data-pp05-4="unpublished"')
    expect(response.body).not_to include('data-photo-gallery-target="dialog"')
  end

  it "shows unavailable state instead of a broken gallery" do
    stub_catalog(catalog(state: :unavailable))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("O serviço está temporariamente indisponível")
    expect(response.body).to include('data-pp05-4="unavailable"')
  end

  it "shows empty published state" do
    stub_catalog(catalog(state: :available))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Nenhuma fotografia encontrada", "Ainda não há fotos disponíveis")
    expect(response.body).to include('data-pp05-4="empty"')
  end

  it "renders next page link for paginated galleries" do
    stub_catalog(catalog(state: :available, photos: [{
      id: photo_id, preview_url: preview, photographer: "",
      captured_at: nil, participant_url: nil
    }], total: 25, has_next: true))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Próxima")
    expect(response.body).to include("page=2")
  end

  it "returns 404 for a missing album" do
    stub_catalog(catalog(state: :not_found))
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:not_found)
  end
end
