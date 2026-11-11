require "rails_helper"

RSpec.describe "PP02.1 Project Bootstrap & Architecture qualification", type: :request do
  it "keeps the Atlas integration behind the versioned public API boundary" do
    configuration = Partilprova::AtlasApi::Configuration.new

    expect(configuration.base_url).to include("/api/public/v1")
  end

  it "does not couple PartilProva to Atlas application code" do
    expect(defined?(Atlas)).to be_nil
  end

  it "keeps the portal root public" do
    get "/"

    expect(response).to have_http_status(:ok)
  end
end
