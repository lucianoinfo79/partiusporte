require "rails_helper"

RSpec.describe "PP-INTEGRATION.11 public registration handoff", type: :request do
  let(:event) do
    { name: "Corrida de Teste", city: "Palmas", state: "TO", date: "2026-10-15",
      description: "", distances: [], routes: [], schedule: [], kit: "", organizer: "",
      venue: "", modality: "Corrida", image_url: nil, regulation_url: nil,
      results_url: nil, photos_url: nil, registration_status: "open",
      registration_provider: "atlas", registration_target: "/events/evt1/editions/ed1/register" }
  end

  def render_event(data)
    result = Partilprova::PublicPortal::EventDetail::Result.new(event: data, state: :available)
    allow_any_instance_of(Partilprova::PublicPortal::EventDetail).to receive(:call).and_return(result)
    get "/eventos/corrida-de-teste"
    expect(response).to have_http_status(:ok)
  end

  it "opens the trusted Atlas registration in the same tab without touching payments" do
    previous_origin = ENV["PARTILPROVA_ATLAS_PUBLIC_ORIGIN"]
    previous_hosts = ENV["PARTILPROVA_REGISTRATION_ALLOWED_HOSTS"]
    ENV["PARTILPROVA_ATLAS_PUBLIC_ORIGIN"] = "https://atlas.example.test"
    ENV["PARTILPROVA_REGISTRATION_ALLOWED_HOSTS"] = "atlas.example.test"

    render_event(event)
    expect(response.body).to include('href="https://atlas.example.test/events/evt1/editions/ed1/register"')
    expect(response.body).to include('data-pp-registration-handoff="atlas"')
    expect(response.body).not_to match(/data-pp-registration-handoff="atlas"[^>]*target="_blank"/)
  ensure
    ENV["PARTILPROVA_ATLAS_PUBLIC_ORIGIN"] = previous_origin
    ENV["PARTILPROVA_REGISTRATION_ALLOWED_HOSTS"] = previous_hosts
  end

  it "does not expose an HTTP localhost registration link in the test environment" do
    previous_origin = ENV["PARTILPROVA_ATLAS_PUBLIC_ORIGIN"]
    ENV["PARTILPROVA_ATLAS_PUBLIC_ORIGIN"] = "http://localhost:3000"

    render_event(event)
    expect(response.body).not_to include('href="http://localhost:3000/events/evt1/editions/ed1/register"')
    expect(response.body).not_to include('data-pp-registration-handoff="atlas"')
  ensure
    ENV["PARTILPROVA_ATLAS_PUBLIC_ORIGIN"] = previous_origin
  end

  it "does not expose a registration action for a closed event" do
    render_event(event.merge(registration_status: "closed"))
    expect(response.body).to include("As inscrições para esta prova estão encerradas")
    expect(response.body).not_to include('data-pp-registration-handoff="atlas"')
  end
end
