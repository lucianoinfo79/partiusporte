require "rails_helper"

RSpec.describe Partilprova::AtlasApi::Configuration do
  it "normalizes the Atlas Public API base URL" do
    config = described_class.new(base_url: "https://atlas.example/api/public/v1/")
    expect(config.base_url).to eq("https://atlas.example/api/public/v1")
    expect(config.uri_for("/events").to_s).to eq("https://atlas.example/api/public/v1/events")
  end

  it "rejects non HTTP(S) Atlas endpoints" do
    expect {
      described_class.new(base_url: "postgres://atlas-db/atlas")
    }.to raise_error(ArgumentError, /HTTP\(S\)/)
  end
end
