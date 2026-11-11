require "rails_helper"

RSpec.describe "PP02.7 registration handoff qualification" do
  it "keeps the Atlas registration URL under explicit trust control" do
    expect(Partilprova::PublicPortal::RegistrationHandoff.new(allowed_hosts: "").call(event: { registration_status: "open", registration_url: "https://example.com/" }).available?).to be(false)
    expect(Rails.root.join("app/assets/stylesheets/pp02_7.css")).to exist
  end
end
