require "rails_helper"

RSpec.describe "PP02.4.1 Home visual parity qualification", type: :request do
  it "loads the dedicated PP02.4 visual layer from the public shell" do
    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('pp02_4')
    expect(response.body).to include('class="pp-hero"')
    expect(response.body).to include('class="pp-modality-list"')
    expect(response.body).to include('class="pp-event-grid"').or include("pp-empty-state")
  end

  it "ships the responsive home component stylesheet" do
    css = Rails.root.join("app/assets/stylesheets/pp02_4.css").read
    expect(css).to include(".pp-hero__grid", ".pp-modality-list", ".pp-event-grid", "@media")
  end
end
