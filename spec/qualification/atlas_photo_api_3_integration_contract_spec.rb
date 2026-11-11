require "rails_helper"

RSpec.describe "ATLAS-PHOTO-API.3 PartilProva integration contract" do
  it "maps Atlas public filter choices without leaking internal identifiers" do
    event = { "photo_filter_options" => {
      "albums" => [{ "id" => "album-public", "name" => "Chegada" }],
      "sessions" => [{ "id" => "session-public", "name" => "Largada" }] } }
    expect(Partilprova::PublicPortal::PhotoGalleryFilterContract.options(event)).to eq(
      albums: [["Chegada", "album-public"]], sessions: [["Largada", "session-public"]]
    )
  end

  it "does not allow filter flags to be enabled by default" do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("PARTILPROVA_ATLAS_PHOTO_GALLERY_FILTERS", "false").and_return("false")
    expect(Partilprova::PublicPortal::PhotoGalleryFilterContract.enabled?).to eq(false)
  end

  it "passes all three validated filters through the public catalog request" do
    client = instance_double(Partilprova::AtlasApi::Client)
    response = double(data: { "data" => { "event" => { "name" => "Prova" }, "published" => true,
      "photos" => [], "filters" => { "albums" => [], "sessions" => [] } },
      "meta" => { "total" => 0 } })
    expect(client).to receive(:get).with("events/prova/photos", params: {
      page: 2, per_page: 24, bib_number: "00123", album_id: "album-public", session_id: "session-public"
    }).and_return(response)
    result = Partilprova::PublicPortal::PhotoCatalog.new(client: client).call(
      event_identifier: "prova", page: 2, bib_number: "00123", album_id: "album-public", session_id: "session-public")
    expect(result.total).to eq(0)
    expect(result.photos).to eq([])
  end
end
