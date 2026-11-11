require "rails_helper"

RSpec.describe "PP02.4.3 Runner Brand & Hero Visual Finalization", type: :request do
  it "renders the official PartilProva logo through the Rails asset pipeline" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('class="pp-brand__official-logo"')
    expect(response.body).to include("partilprova-logo")
  end

  it "renders the approved runner photo without the provisional hero composition" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("green-runner-hero", "pp-hero__runner-photo")
    expect(response.body).not_to include('<div class="pp-hero__number">01</div>')
    expect(response.body).not_to include("<strong>PARTIL</strong><span>PROVA</span>")
  end

  it "loads the active home visual stylesheets" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("pp02_4-", "pp02_4_6-")
    expect(Rails.root.join("app/assets/stylesheets/pp02_4.css")).to exist
    expect(Rails.root.join("app/assets/stylesheets/pp02_4_6.css")).to exist
  end
end
