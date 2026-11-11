require "rails_helper"

RSpec.describe "PP02.2 Design System & Public Shell qualification", type: :request do
  it "exposes the approved responsive public shell" do
    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("pp-header", "pp-mobile-menu", "pp-footer")
  end

  it "ships reusable visual primitives without coupling the shell to Atlas internals" do
    css = Rails.root.join("app/assets/stylesheets/application.css").read

    expect(css).to include("--pp-brand:", "--pp-navy:", ".pp-button--primary", ".pp-event-card", "@media")
    expect(css).not_to include("Atlas::")
  end
end
