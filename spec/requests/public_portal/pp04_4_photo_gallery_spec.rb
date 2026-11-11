require "rails_helper"

RSpec.describe "PP04.4 public photo gallery", type: :request do
  let(:preview) { "/eventos/prova/fotos/123e4567-e89b-12d3-a456-426614174000/preview" }

  it "renders an accessible protected-photo viewer using the catalog preview" do
    result = Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: :available, event: { "name" => "Corrida do Parque" },
      photos: [{ id: "123e4567-e89b-12d3-a456-426614174000", preview_url: preview,
                 photographer: "Equipe Foto", captured_at: nil, participant_url: nil }],
      page: 1, total: 1, has_next: false, participant_url: nil)
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(result)
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("data-controller=\"photo-gallery\"")
    expect(response.body).to include("data-photo-gallery-target=\"dialog\"")
    expect(response.body).to include("Ampliar fotografia 1", "Equipe Foto", preview)
    expect(response.body).not_to include("original_url", "master_url")
  end
end
