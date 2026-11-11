require "rails_helper"

RSpec.describe "PP02.4.7 Hero Runner Image Sizing & Framing", type: :request do
  it "loads the final hero framing stylesheet" do
    get "/"
    expect(response).to have_http_status(:ok)

    css = Rails.root.join("app/assets/stylesheets/pp02_4_7.css")
    expect(css).to exist
    expect(css.read).to include(
      ".pp-hero__visual--runner",
      ".pp-hero__runner-photo",
      "object-fit: contain"
    )
  end
end
