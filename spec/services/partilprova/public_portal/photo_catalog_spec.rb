require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoCatalog do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:service) { described_class.new(client: client) }

  it "fetches public protected previews and pagination" do
    payload = { "event" => { "name" => "Corrida" }, "published" => true,
      "photos" => [{ "id" => 1, "preview_url" => "https://cdn.example.com/preview.jpg" }],
      "meta" => { "total" => 25 } }
    expect(client).to receive(:get).with("events/prova/photos", params: { page: 1, per_page: 24 }).and_return(double(data: { "data" => payload, "meta" => { "total" => 25 } }))
    result = service.call(event_identifier: "prova")
    expect(result.available?).to eq(true)
    expect(result.photos.first[:id]).to eq(1)
    expect(result.has_next).to eq(true)
  end

  it "does not expose unpublished photos" do
    allow(client).to receive(:get).and_return(double(data: { "published" => false, "photos" => [{ "preview_url" => "https://cdn.example.com/p.jpg" }] }))
    expect(service.call(event_identifier: "prova").photos).to be_empty
  end

  it "rejects unsafe image URLs and unapproved participant links" do
    allow(client).to receive(:get).and_return(double(data: {
      "photos" => [{ "preview_url" => "javascript:alert(1)" }],
      "participant_url" => "https://attacker.example/portal" }))
    result = service.call(event_identifier: "prova")
    expect(result.photos).to be_empty
    expect(result.participant_url).to be_nil
  end

  it "fails closed on Atlas transport errors" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::TransportError, "offline")
    expect(service.call(event_identifier: "prova").state).to eq(:unavailable)
  end
end
