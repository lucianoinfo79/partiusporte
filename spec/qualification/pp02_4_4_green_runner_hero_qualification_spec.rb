require "rails_helper"

RSpec.describe "PP02.4.4 Accepted green runner hero", type: :request do
  it "renders the accepted green runner artwork through the Rails asset pipeline" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("green-runner-hero", "pp-hero__runner-photo")
    expect(response.body).not_to include('<div class="pp-hero__number">01</div>')
    expect(response.body).not_to include("<strong>PARTIL</strong><span>PROVA</span>")
  end

  it "loads the active hero visual stylesheet and image" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("pp02_4_6-")
    expect(Rails.root.join("app/assets/stylesheets/pp02_4_6.css")).to exist
    expect(Rails.root.join("app/assets/images/partilprova/green-runner-hero.jpg")).to exist
  end
end
