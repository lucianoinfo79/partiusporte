require "rails_helper"

RSpec.describe "PP02.2.1 Rails/JSON session serialization compatibility", type: :request do
  before do
    stub_const(
      "Pp02SessionProbeController",
      Class.new(ApplicationController) do
        def index
          session[:pp02_2_1_probe] = {
            "portal" => "partilprova",
            "ok" => true
          }

          head :ok
        end
      end
    )

    Rails.application.routes.draw do
      get "pp02_2_1/session_probe" => "pp02_session_probe#index"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  it "commits a session cookie without a JSON generator ArgumentError" do
    expect {
      get "/pp02_2_1/session_probe"
    }.not_to raise_error

    expect(response).to have_http_status(:ok)
    expect(response.headers["Set-Cookie"]).to be_present
  end
end
