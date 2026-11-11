require "rails_helper"
RSpec.describe "PP02.6 qualification", type: :request do
  it "exposes the public event detail route and visual asset" do
    expect(Rails.application.routes.url_helpers.public_event_path("prova")).to eq("/eventos/prova")
    expect(Rails.root.join("app/assets/stylesheets/pp02_6.css")).to exist
  end
end
