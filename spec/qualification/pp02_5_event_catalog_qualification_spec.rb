require "rails_helper"

RSpec.describe "PP02.5 catalog qualification", type: :request do
  it "has a routable public catalog and a dedicated stylesheet" do
    expect(Rails.application.routes.url_helpers.public_events_path).to eq("/eventos")
    expect(Rails.root.join("app/assets/stylesheets/pp02_5.css")).to exist
    expect(Partilprova::PublicPortal::EventCatalog::PAGE_SIZE).to eq(12)
  end
end
