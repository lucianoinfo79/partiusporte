require "rails_helper"

RSpec.describe "PartilProva public portal", type: :request do
  it "serves the public home without authentication" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("PartilProva")
  end
end
