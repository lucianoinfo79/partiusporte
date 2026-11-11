require "rails_helper"

RSpec.describe "PP02.9 photos and participant handoff qualification" do
  it "registers public photo routes and styles" do
    helpers = Rails.application.routes.url_helpers
    expect(helpers.public_photos_path).to eq("/fotos")
    expect(helpers.public_event_photos_path("prova")).to eq("/eventos/prova/fotos")
    expect(Rails.root.join("app/assets/stylesheets/pp02_9.css")).to exist
  end
end
