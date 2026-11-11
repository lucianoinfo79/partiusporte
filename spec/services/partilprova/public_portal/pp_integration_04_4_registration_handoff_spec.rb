require "rails_helper"

RSpec.describe "PP-INTEGRATION.04.4 registration handoff" do
  let(:service) do
    Partilprova::PublicPortal::RegistrationHandoff.new(
      allowed_hosts: "inscricoes.example",
      atlas_public_origin: "https://inscricoes.example"
    )
  end

  it "opens an Atlas registration only with a trusted HTTPS origin and valid Atlas route" do
    result = service.call(event: {
      registration_provider: "atlas", registration_status: "open",
      registration_target: "/events/event123/editions/edition456/register"
    })
    expect(result.state).to eq(:available)
    expect(result.url).to eq("https://inscricoes.example/events/event123/editions/edition456/register")
  end

  it "does not offer an Atlas registration when the public origin is missing" do
    result = Partilprova::PublicPortal::RegistrationHandoff.new(
      allowed_hosts: "inscricoes.example", atlas_public_origin: ""
    ).call(event: {
      registration_provider: "atlas", registration_status: "open",
      registration_target: "/events/event123/editions/edition456/register"
    })
    expect(result.state).to eq(:missing)
    expect(result.url).to be_nil
  end

  it "keeps the CTA blocked when Atlas reports unavailable" do
    result = service.call(event: {
      registration_provider: "atlas", registration_status: "unavailable",
      registration_target: "/events/event123/editions/edition456/register"
    })
    expect(result.state).to eq(:unavailable)
    expect(result.url).to be_nil
  end
end
