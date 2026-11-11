require "rails_helper"

RSpec.describe "PP02.8 results qualification" do
  it "exposes public results routes and styles" do
    routes = Rails.application.routes.url_helpers
    expect(routes.public_results_path).to eq("/resultados")
    expect(routes.public_event_results_path("prova")).to eq("/eventos/prova/resultados")
    expect(Rails.root.join("app/assets/stylesheets/pp02_8.css")).to exist
  end
end
