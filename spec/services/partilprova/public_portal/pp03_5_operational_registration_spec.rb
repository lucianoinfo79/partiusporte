require "rails_helper"

RSpec.describe "PP03.5 operational registration handoff" do
  let(:service) do
    Partilprova::PublicPortal::RegistrationHandoff.new(
      allowed_hosts: "atlas.example,organizador.example",
      atlas_public_origin: "https://atlas.example"
    )
  end

  it "resolves Atlas relative registration target against the authorized public origin" do
    result = service.call(event: {
      registration_status: "open", registration_provider: "atlas",
      registration_target: "/events/event_1/editions/edition_2/register"
    })
    expect(result).to be_available
    expect(result.url).to eq("https://atlas.example/events/event_1/editions/edition_2/register")
  end

  it "accepts an allowlisted external organizer destination" do
    result = service.call(event: {
      registration_status: "open", registration_provider: "external",
      registration_url: "https://organizador.example/inscricao"
    })
    expect(result).to be_available
  end

  it "does not turn arbitrary Atlas targets into public URLs" do
    ["//evil.example/path", "/admin", "/events/1/editions/2/register?next=evil", "https://evil.example"].each do |target|
      result = service.call(event: { registration_status: "open", registration_provider: "atlas", registration_target: target })
      expect(result).not_to be_available
    end
  end

  it "requires a trusted HTTPS Atlas public origin" do
    result = Partilprova::PublicPortal::RegistrationHandoff.new(allowed_hosts: "atlas.example", atlas_public_origin: "http://atlas.example").call(
      event: { registration_status: "open", registration_provider: "atlas", registration_target: "/events/1/editions/2/register" }
    )
    expect(result).not_to be_available
  end

  it "does not hand off closed registrations" do
    result = service.call(event: {
      registration_status: "closed", registration_provider: "atlas",
      registration_target: "/events/1/editions/2/register"
    })
    expect(result.state).to eq(:closed)
  end

  it "normalizes the routing contract from Atlas detail response" do
    client = instance_double(Partilprova::AtlasApi::Client)
    allow(client).to receive(:get).and_return(double(data: { "data" => {
      "name" => "Prova", "registration" => { "status" => "open", "provider" => "atlas", "target" => "/events/1/editions/2/register" }
    } }))
    detail = Partilprova::PublicPortal::EventDetail.new(client: client).call(identifier: "prova")
    expect(detail.event[:registration_target]).to eq("/events/1/editions/2/register")
    expect(service.call(event: detail.event)).to be_available
  end
end
