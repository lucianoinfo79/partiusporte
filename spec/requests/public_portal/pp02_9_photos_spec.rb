require "rails_helper"

RSpec.describe "PP02.9 public photos", type: :request do
  it "renders the public photos landing page" do
    get "/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Fotos das provas")
  end

  it "renders an empty published album" do
    result = Partilprova::PublicPortal::PhotoCatalog::Result.new(
      state: :available, event: { "name" => "Corrida do Parque" },
      photos: [], page: 1, total: 0, has_next: false, participant_url: nil)
    allow_any_instance_of(Partilprova::PublicPortal::PhotoCatalog).to receive(:call).and_return(result)
    get "/eventos/prova/fotos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Corrida do Parque", "Nenhuma foto publicada")
  end
end
