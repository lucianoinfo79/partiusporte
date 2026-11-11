require "rails_helper"

RSpec.describe Partilprova::PublicPortal::RegistrationHandoff, "PP-INTEGRATION.03.3" do
  let(:service) { described_class.new(allowed_hosts: "organizador.example,atlas.example",
    atlas_public_origin: "https://atlas.example") }

  it "does not offer registration for an unavailable provider even if a URL exists" do
    result = service.call(event: { registration_provider: "unavailable",
      registration_status: "open", registration_url: "https://organizador.example/inscricao" })
    expect(result.state).to eq(:unavailable)
  end

  it "blocks a provider whose registration window is not open" do
    result = service.call(event: { registration_provider: "external",
      registration_status: "upcoming", registration_target: "https://organizador.example/inscricao" })
    expect(result.state).to eq(:not_open)
  end

  it "accepts the Atlas-issued external registration target" do
    result = service.call(event: { registration_provider: "external",
      registration_status: "open", registration_target: "https://organizador.example/inscricao" })
    expect(result.url).to eq("https://organizador.example/inscricao")
  end

  it "resolves the Atlas public route only through the configured public origin" do
    result = service.call(event: { registration_provider: "atlas", registration_status: "open",
      registration_target: "/events/abc/editions/def/register" })
    expect(result.url).to eq("https://atlas.example/events/abc/editions/def/register")
  end

  it "does not open registration for an unknown Atlas status" do
    result = service.call(event: { registration_provider: "atlas", registration_status: nil,
      registration_target: "/events/abc/editions/def/register" })
    expect(result.state).to eq(:unknown)
    expect(result.url).to be_nil
  end
end
