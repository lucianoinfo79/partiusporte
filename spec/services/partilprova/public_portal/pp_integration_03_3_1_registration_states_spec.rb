require "rails_helper"

RSpec.describe Partilprova::PublicPortal::RegistrationHandoff, "PP-INTEGRATION.03.3.1" do
  subject(:service) do
    described_class.new(allowed_hosts: "organizador.example",
      atlas_public_origin: "https://organizador.example")
  end

  let(:destination) { "https://organizador.example/inscricao" }

  {
    "unavailable" => :unavailable,
    "upcoming" => :not_open,
    "not_open" => :not_open,
    "closed" => :closed,
    "sold_out" => :sold_out,
    "full" => :sold_out,
    "cancelled" => :cancelled,
    "canceled" => :cancelled,
    "unexpected" => :unknown
  }.each do |status, state|
    it "blocks #{status} and reports #{state} even without a provider" do
      result = service.call(event: { registration_status: status, registration_url: destination })
      expect(result.state).to eq(state)
      expect(result.url).to be_nil
    end
  end

  it "never opens a registration with an unavailable provider even when status is open" do
    result = service.call(event: { registration_provider: "unavailable",
      registration_status: "open", registration_url: destination })
    expect(result.state).to eq(:unavailable)
  end

  it "allows a trusted registration only when Atlas explicitly reports open" do
    result = service.call(event: { registration_status: "open", registration_url: destination })
    expect(result.state).to eq(:available)
    expect(result.url).to eq(destination)
  end

  it "does not open registrations with no known status" do
    result = service.call(event: { registration_status: nil, registration_url: destination })
    expect(result.state).to eq(:unknown)
  end
end
