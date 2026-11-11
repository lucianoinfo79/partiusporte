require "rails_helper"

RSpec.describe "PP02.8 public results", type: :request do
  it "renders the public results landing page" do
    get "/resultados"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Resultados das provas")
  end

  it "renders published results for an event" do
    result = Partilprova::PublicPortal::RaceResults::Result.new(
      state: :available, event: { "name" => "Corrida do Parque" },
      rows: [{ position: 1, bib: "123", name: "Ana", category: "F30",
               time: "00:24:30", gross_time: "00:25:00", status: "finished" }],
      categories: ["F30"], page: 1, has_next: false, total: 1, filters: { q: "", category: "" })
    allow_any_instance_of(Partilprova::PublicPortal::RaceResults).to receive(:call).and_return(result)
    get "/eventos/prova/resultados"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Corrida do Parque", "00:24:30", "Ana")
  end
end
