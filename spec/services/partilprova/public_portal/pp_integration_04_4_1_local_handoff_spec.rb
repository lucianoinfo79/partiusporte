require "rails_helper"

RSpec.describe Partilprova::PublicPortal::RegistrationHandoff, "PP-INTEGRATION.04.4.1" do
  let(:event) do
    { registration_provider: "atlas", registration_status: "open",
      registration_target: "/events/event123/editions/edition456/register" }
  end
  let(:local_service) do
    described_class.new(atlas_public_origin: "http://localhost:3000", allowed_hosts: "")
  end

  it "allows the precise localhost Atlas route in development without a global HTTP allowlist" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    result = local_service.call(event: event)
    expect(result.state).to eq(:available)
    expect(result.url).to eq("http://localhost:3000/events/event123/editions/edition456/register")
  end

  %w[test production].each do |environment|
    it "rejects localhost in #{environment}" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
      expect(local_service.call(event: event).available?).to be(false)
    end
  end

  it "does not trust external HTTP localhost even in development" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    result = local_service.call(event: event.merge(registration_provider: "external",
      registration_target: "http://localhost:3000/events/event123/editions/edition456/register"))
    expect(result.state).to eq(:untrusted)
  end

  it "rejects an unexpected local port" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    result = described_class.new(atlas_public_origin: "http://localhost:3002", allowed_hosts: "").call(event: event)
    expect(result.available?).to be(false)
  end

  it "rejects an arbitrary local path" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    result = local_service.call(event: event.merge(registration_target: "/admin"))
    expect(result.available?).to be(false)
  end

  it "keeps the registration blocked if Atlas reports unavailable" do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
    result = local_service.call(event: event.merge(registration_status: "unavailable"))
    expect(result.state).to eq(:unavailable)
  end
end
