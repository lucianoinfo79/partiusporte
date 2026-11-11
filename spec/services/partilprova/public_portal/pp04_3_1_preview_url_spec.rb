require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoCatalog do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:service) { described_class.new(client: client) }
  let(:photo_id) { "f2e0ed76-dd93-42b4-9e11-154ac1567804" }

  def catalog(url)
    allow(client).to receive(:get).and_return(double(data: {
      "published" => true, "event" => { "name" => "Teste" },
      "photos" => [{ "id" => photo_id, "preview_url" => url }], "meta" => { "total" => 1 }
    }))
    service.call(event_identifier: "evento-oportunidade-teste")
  end

  it "retains HTTPS image URLs" do
    expect(catalog("https://cdn.example.test/preview.jpg").photos.first[:preview_url]).to eq("https://cdn.example.test/preview.jpg")
  end

  it "never accepts an unrelated HTTP host" do
    expect(catalog("http://evil.example.test/preview").photos).to be_empty
  end

  it "does not expose HTTP Atlas preview URLs unless development opt-in is active" do
    url = "http://host.docker.internal:3000/api/public/v1/events/evento-oportunidade-teste/photos/#{photo_id}/preview?token=secret"
    allow(ENV).to receive(:[]).with("PP0431_LOCAL_PREVIEW_PROXY").and_return(nil)
    expect(catalog(url).photos).to be_empty
  end
end
