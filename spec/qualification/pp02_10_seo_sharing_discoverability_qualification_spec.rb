require "rails_helper"

RSpec.describe "PP02.10 qualification" do
  it "has sitemap, robots and event structured data helper" do
    routes = Rails.application.routes.url_helpers
    expect(routes.robots_path).to eq("/robots.txt")
    expect(routes.sitemap_path).to eq("/sitemap.xml")
    expect(PublicPortal::EventSeoHelper.instance_methods).to include(:pp_event_json_ld)
  end
end
