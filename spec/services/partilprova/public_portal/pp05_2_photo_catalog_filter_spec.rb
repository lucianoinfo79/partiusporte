require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoCatalog do
  it "passes a server-side bib filter to Atlas without downloading unfiltered pages" do
    client = instance_double(Partilprova::AtlasApi::Client)
    expect(client).to receive(:get).with("events/prova/photos", params: {
      page: 1, per_page: 24, bib_number: "009001"
    }).and_return(double(data: { "data" => { "published" => true, "photos" => [] }, "meta" => { "total" => 0 } }))
    result = described_class.new(client: client).call(event_identifier: "prova", page: 1, bib_number: "009001")
    expect(result.available?).to eq(true)
    expect(result.photos).to be_empty
  end
end
