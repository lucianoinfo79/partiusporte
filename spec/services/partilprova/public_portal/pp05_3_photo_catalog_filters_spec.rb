require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoCatalog do
  it "forwards event-scoped album and session filters to Atlas without local filtering" do
    client = instance_double(Partilprova::AtlasApi::Client)
    expect(client).to receive(:get).with("events/prova/photos", params: {
      page: 1, per_page: 24, album_id: "a1", session_id: "s1"
    }).and_return(double(data: { "data" => { "published" => true, "photos" => [],
      "filters" => { "albums" => [{ "id" => "a1", "name" => "Largada" }] } },
      "meta" => { "total" => 0 } }))
    result = described_class.new(client: client).call(event_identifier: "prova", album_id: "a1", session_id: "s1")
    expect(result.available?).to eq(true)
    expect(result.event["photo_filter_options"]["albums"].first["id"]).to eq("a1")
  end
end
