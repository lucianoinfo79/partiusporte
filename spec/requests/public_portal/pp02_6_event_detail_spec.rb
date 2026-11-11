require "rails_helper"
RSpec.describe "PP02.6 public event details", type: :request do
  it "renders the detail page with real data from the service" do
    result = Partilprova::PublicPortal::EventDetail::Result.new(
      event: { name: "Corrida do Parque", city: "Palmas", state: "TO", date: "2026-10-15",
        description: "Corrida de rua", distances: ["5 km"], routes: [], schedule: [],
        kit: "", organizer: "", venue: "", modality: "Corrida", registration_status: "open",
        image_url: nil, registration_url: nil, regulation_url: nil, results_url: nil, photos_url: nil },
      state: :available
    )
    allow_any_instance_of(Partilprova::PublicPortal::EventDetail).to receive(:call).and_return(result)
    get "/eventos/corrida-do-parque"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Corrida do Parque", "Percursos e distâncias", "Kit do atleta")
  end
end
