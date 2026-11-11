require "rails_helper"

RSpec.describe Partilprova::PublicPortal::RegistrationHandoff do
  subject(:service) { described_class.new(allowed_hosts: "inscricoes.atlas.example,organizador.example") }

  it "accepts an authorized HTTPS destination" do
    result = service.call(event: { registration_status: "open", registration_url: "https://inscricoes.atlas.example/evento/12" })
    expect(result).to be_available
    expect(result.url).to eq("https://inscricoes.atlas.example/evento/12")
  end

  it "blocks domains outside the allowlist" do
    result = service.call(event: { registration_status: "open", registration_url: "https://evil.example/evento/12" })
    expect(result.state).to eq(:untrusted)
  end

  it "blocks HTTP, credentials and IP literal URLs" do
    ["http://inscricoes.atlas.example/", "https://user@inscricoes.atlas.example/", "https://127.0.0.1/"].each do |url|
      expect(service.call(event: { registration_status: "open", registration_url: url }).available?).to be(false)
    end
  end

  it "blocks registrations with a distinct reason for closed, cancelled and sold out" do
    { "closed" => :closed, "cancelled" => :cancelled, "sold_out" => :sold_out }.each do |status, state|
      result = service.call(event: { registration_status: status, registration_url: "https://inscricoes.atlas.example/" })
      expect(result.state).to eq(state)
      expect(result.url).to be_nil
      expect(result).not_to be_available
    end
  end

  it "does not generate a destination without an Atlas URL" do
    expect(service.call(event: { registration_status: "open", registration_url: nil }).state).to eq(:missing)
  end

  it "fails closed when no hosts are configured" do
    result = described_class.new(allowed_hosts: "").call(event: { registration_status: "open", registration_url: "https://inscricoes.atlas.example/" })
    expect(result.state).to eq(:untrusted)
  end
end
