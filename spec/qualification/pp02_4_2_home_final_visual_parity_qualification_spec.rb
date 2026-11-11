require "rails_helper"

RSpec.describe "PP02.4.2 Home final visual parity qualification", type: :request do
  it "renders the approved official brand instead of the legacy green arrow" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('class="pp-brand__official-logo"')
    expect(response.body).to include("partilprova-logo")
    expect(response.body).not_to include(">➜</span>")
  end

  it "ships the approved logo, runner photo and home visual layer" do
    css = Rails.root.join("app/assets/stylesheets/pp02_4.css").read
    expect(css).to include(".pp-home-search", ".pp-modality-list")
    expect(Rails.root.join("app/assets/images/partilprova/partilprova-logo.png")).to exist
    expect(Rails.root.join("app/assets/images/partilprova/green-runner-hero.jpg")).to exist
  end
end
