require "rails_helper"

RSpec.describe "PP03.9 operational integration regression gate" do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }

  it "preserves public routes across the operational journey" do
    routes = Rails.application.routes.url_helpers
    expect(routes.public_events_path).to eq("/eventos")
    expect(routes.public_event_path("corrida")).to eq("/eventos/corrida")
    expect(routes.public_event_results_path("corrida")).to eq("/eventos/corrida/resultados")
    expect(routes.public_event_photos_path("corrida")).to eq("/eventos/corrida/fotos")
  end

  it "keeps publication decisions authoritative at Atlas and filters explicitly hidden catalog entries" do
    payload = { "data" => [
      { "id" => 1, "slug" => "publicada", "name" => "Prova publicada", "publication_status" => "published", "registration_status" => "closed" },
      { "id" => 2, "slug" => "oculta", "name" => "Prova oculta", "publication_status" => "hidden" }
    ], "meta" => { "total" => 2 } }
    allow(client).to receive(:get).and_return(Partilprova::AtlasApi::Response.new(status: 200, headers: {}, data: payload, raw_body: ""))
    result = Partilprova::PublicPortal::EventCatalog.new(client: client).call
    expect(result.available).to eq(true)
    expect(result.events.map { |event| event[:slug] }).to eq(["publicada"])
  end

  it "rejects an insecure registration origin rather than redirecting an athlete" do
    handoff = Partilprova::PublicPortal::RegistrationHandoff.new(
      allowed_hosts: "atlas.example", atlas_public_origin: "http://atlas.example"
    )
    result = handoff.call(event: {
      registration_status: "open", registration_provider: "atlas",
      registration_target: "/events/1/editions/2/register"
    })
    expect(result.available?).to eq(false)
    expect(result.url).to be_nil
  end

  it "never represents unsupported classification filters as applied" do
    expect(client).not_to receive(:get)
    result = Partilprova::PublicPortal::RaceResults.new(client: client).call(
      event_identifier: "corrida", q: "Ana"
    )
    expect(result.state).to eq(:filters_unsupported)
    expect(result.available?).to eq(false)
  end

  it "does not classify an HTTP upstream failure as healthy" do
    response = Partilprova::AtlasApi::Response.new(status: 403, headers: {}, data: {}, raw_body: "")
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::HttpError.new(response))
    result = Partilprova::AtlasApi::Availability.new(client: client).call
    expect(result.state).to eq(:unavailable)
    expect(result.http_status).to eq(403)
  end
end
