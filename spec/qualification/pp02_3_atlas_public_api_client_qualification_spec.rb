require "rails_helper"

RSpec.describe "PP02.3 Atlas Public API Client qualification" do
  it "loads the complete public API client boundary through Zeitwerk" do
    expect(Partilprova::AtlasApi::Configuration).to be_a(Class)
    expect(Partilprova::AtlasApi::Client).to be_a(Class)
    expect(Partilprova::AtlasApi::NetHttpTransport).to be_a(Class)
    expect(Partilprova::AtlasApi::Response).to be_a(Class)
    expect(Partilprova::AtlasApi::HttpError).to be < Partilprova::AtlasApi::Error
    expect(Partilprova::AtlasApi::TimeoutError).to be < Partilprova::AtlasApi::TransportError
  end

  it "keeps Atlas addressing and timeouts outside controllers and views" do
    configuration = Partilprova::AtlasApi::Configuration.new(
      base_url: "https://atlas.example/api/public/v1",
      open_timeout: "3",
      read_timeout: "8"
    )

    expect(configuration.base_url).to eq("https://atlas.example/api/public/v1")
    expect(configuration.open_timeout).to eq(3)
    expect(configuration.read_timeout).to eq(8)
  end
end
