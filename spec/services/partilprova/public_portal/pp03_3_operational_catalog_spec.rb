require "rails_helper"

RSpec.describe "PP03.3 operational catalog", type: :service do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:catalog) { Partilprova::PublicPortal::EventCatalog.new(client: client) }

  def response(events, meta = {})
    double(data: { "events" => events, "meta" => meta })
  end

  it "shows published editions even when registration is closed" do
    allow(client).to receive(:get).and_return(response([
      { "id" => 1, "name" => "Corrida", "publication_status" => "published", "registration_status" => "closed" }
    ]))
    result = catalog.call
    expect(result.events.map { |e| e[:id] }).to eq([1])
    expect(result.events.first[:registration_status]).to eq("closed")
  end

  it "excludes explicitly hidden, archived, draft and unpublished records" do
    events = %w[hidden archived draft unpublished].each_with_index.map do |state, i|
      { "id" => i, "publication_status" => state }
    end
    events << { "id" => 9, "publication_status" => "published" }
    allow(client).to receive(:get).and_return(response(events))
    expect(catalog.call.events.map { |e| e[:id] }).to eq([9])
  end

  it "does not treat generic event status as registration status" do
    allow(client).to receive(:get).and_return(response([{ "id" => 1, "status" => "published" }]))
    expect(catalog.call.events.first[:registration_status]).to be_nil
  end

  it "preserves Atlas pagination metadata after defensive filtering" do
    allow(client).to receive(:get).and_return(response([
      { "id" => 1, "publication_status" => "hidden" }
    ], { "total" => 30, "has_next" => true }))
    result = catalog.call
    expect(result.events).to be_empty
    expect(result.total).to eq(30)
    expect(result.has_next).to eq(true)
  end
end
