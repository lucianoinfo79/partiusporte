require "rails_helper"
RSpec.describe "PP02.4.6 Official PartilProva logo image", type: :request do
  it "renders the supplied official logo as one image" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("partilprova-logo", "pp-brand__official-logo", "pp02_4_6")
  end
  it "ships the supplied logo asset" do
    expect(Rails.root.join("app/assets/images/partilprova/partilprova-logo.png")).to exist
  end
end
