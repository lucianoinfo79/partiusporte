require "rails_helper"

RSpec.describe "PP-INTEGRATION.09.5.18.1 PartilProva runtime handoff" do
  let(:event) do
    { registration_provider: "atlas", registration_status: "open",
      registration_target: "/events/event123/editions/edition456/register" }
  end
  let(:service) do
    Partilprova::PublicPortal::RegistrationHandoff.new(
      allowed_hosts: "atlas.example,organizer.example", atlas_public_origin: "https://atlas.example"
    )
  end

  it "resolves an Atlas-issued target to the public HTTPS origin" do
    result = service.call(event: event)
    expect(result.state).to eq(:available)
    expect(result.url).to eq("https://atlas.example/events/event123/editions/edition456/register")
  end

  it "blocks unknown hosts and arbitrary paths" do
    expect(service.call(event: event.merge(registration_target: "/admin")).available?).to be(false)
    untrusted = Partilprova::PublicPortal::RegistrationHandoff.new(allowed_hosts: "organizer.example", atlas_public_origin: "https://atlas.example")
    expect(untrusted.call(event: event).available?).to be(false)
  end

  it "blocks closed and unavailable Atlas registrations" do
    { "closed" => :closed, "sold_out" => :sold_out, "cancelled" => :cancelled,
      "unavailable" => :unavailable }.each do |status, expected|
      result = service.call(event: event.merge(registration_status: status))
      expect(result.state).to eq(expected)
      expect(result.url).to be_nil
    end
  end

  it "does not redirect external registrations to Atlas" do
    result = service.call(event: event.merge(registration_provider: "external",
      registration_target: "https://organizer.example/register"))
    expect(result.url).to eq("https://organizer.example/register")
  end

  it "does not trust external localhost or unexpected URL schemes" do
    ["http://localhost:3000/register", "javascript:alert(1)"].each do |url|
      result = service.call(event: event.merge(registration_provider: "external", registration_target: url))
      expect(result.available?).to be(false)
    end
  end
end
