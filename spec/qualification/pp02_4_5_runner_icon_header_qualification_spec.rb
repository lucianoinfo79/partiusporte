require "rails_helper"

RSpec.describe "PP02.4.5 Runner icon header qualification", type: :request do
  it "renders the approved official logo in the public header" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/class="pp-brand"[^>]*>\s*<img[^>]*class="pp-brand__official-logo"/m)
    expect(response.body).to include("partilprova-logo")
    expect(response.body).not_to include('class="pp-brand__runner"')
  end

  it "ships the approved official logo asset" do
    expect(Rails.root.join("app/assets/images/partilprova/partilprova-logo.png")).to exist
  end
end
