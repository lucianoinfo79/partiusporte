require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoCatalog do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:service) { described_class.new(client: client) }

  it "reads the Atlas v1 data envelope and root pagination metadata" do
    payload = { "data" => { "event" => { "name" => "Prova" }, "published" => true,
      "photos" => [{ "id" => 7, "preview_url" => "https://cdn.example.org/protected.jpg" }] },
      "meta" => { "total" => 30 } }
    allow(client).to receive(:get).and_return(double(data: payload))
    result = service.call(event_identifier: "prova")
    expect(result.available?).to eq(true)
    expect(result.photos.map { |photo| photo[:id] }).to eq([7])
    expect(result.has_next).to eq(true)
  end

  it "does not show explicitly hidden editions" do
    allow(client).to receive(:get).and_return(double(data: {
      "event" => { "publication_status" => "hidden" }, "photos" => [
        { "preview_url" => "https://cdn.example.org/protected.jpg" }] }))
    result = service.call(event_identifier: "prova")
    expect(result.unpublished?).to eq(true)
    expect(result.photos).to be_empty
  end

  it "never uses original or private asset URLs as a preview" do
    allow(client).to receive(:get).and_return(double(data: { "photos" => [
      { "id" => 1, "original_url" => "https://cdn.example.org/original.jpg" },
      { "id" => 2, "preview_url" => "http://cdn.example.org/unsafe.jpg" }] }))
    expect(service.call(event_identifier: "prova").photos).to be_empty
  end

  it "rejects participant handoffs to hosts outside the allowlist" do
    allow(client).to receive(:get).and_return(double(data: {
      "photos" => [], "participant_url" => "https://unknown.example.org/athlete" }))
    expect(service.call(event_identifier: "prova").participant_url).to be_nil
  end
end
