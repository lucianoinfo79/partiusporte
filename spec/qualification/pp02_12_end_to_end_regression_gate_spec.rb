require "rails_helper"

RSpec.describe "PP02.12 end-to-end regression gate" do
  it "keeps the complete public route contract" do
    routes = Rails.application.routes.url_helpers
    expect(routes.root_path).to eq("/")
    expect(routes.public_events_path).to eq("/eventos")
    expect(routes.public_event_path("prova")).to eq("/eventos/prova")
    expect(routes.public_results_path).to eq("/resultados")
    expect(routes.public_event_results_path("prova")).to eq("/eventos/prova/resultados")
    expect(routes.public_photos_path).to eq("/fotos")
    expect(routes.public_event_photos_path("prova")).to eq("/eventos/prova/fotos")
    expect(routes.robots_path).to eq("/robots.txt")
    expect(routes.sitemap_path).to eq("/sitemap.xml")
  end

  it "preserves Atlas API integration, SEO and public page services" do
    expect(Partilprova::AtlasApi::Client.instance_methods(false)).to include(:get)
    expect(Partilprova::PublicPortal::EventDetail.instance_methods(false)).to include(:call)
    expect(Partilprova::PublicPortal::EventCatalog.instance_methods(false)).to include(:call)
    expect(Partilprova::PublicPortal::RaceResults.instance_methods(false)).to include(:call)
    expect(Partilprova::PublicPortal::PhotoCatalog.instance_methods(false)).to include(:call)
    expect(PublicPortal::EventSeoHelper.instance_methods).to include(:pp_event_json_ld)
  end
end
