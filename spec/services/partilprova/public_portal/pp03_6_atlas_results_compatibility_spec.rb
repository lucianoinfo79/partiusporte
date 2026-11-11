require "rails_helper"

RSpec.describe Partilprova::PublicPortal::RaceResults do
  let(:client) { instance_double(Partilprova::AtlasApi::Client) }
  let(:service) { described_class.new(client: client) }

  it "reads Atlas v1 data array, pagination metadata and seconds" do
    expect(client).to receive(:get).with("events/corrida/results", params: { page: 1, per_page: 30 })
      .and_return(double(data: { "data" => [
        { "bib_number" => "42", "athlete_name" => "Ana", "category" => "Geral", "net_seconds" => 1503, "gross_seconds" => 1512 }
      ], "meta" => { "page" => 1, "per_page" => 30, "total" => 31 } }))
    result = service.call(event_identifier: "corrida")
    expect(result.available?).to be(true)
    expect(result.rows.first).to include(bib: "42", name: "Ana", time: "00:25:03", gross_time: "00:25:12")
    expect(result.has_next).to be(true)
  end

  it "does not falsely apply unsupported search filters" do
    expect(client).not_to receive(:get)
    result = service.call(event_identifier: "corrida", q: "Ana")
    expect(result.state).to eq(:filters_unsupported)
    expect(result.rows).to be_empty
  end

  it "keeps unpublished results hidden for legacy responses" do
    allow(client).to receive(:get).and_return(double(data: { "published" => false, "results" => [{ "athlete_name" => "Privado" }] }))
    expect(service.call(event_identifier: "corrida").unpublished?).to be(true)
  end

  it "distinguishes an unknown public event" do
    allow(client).to receive(:get).and_raise(Partilprova::AtlasApi::HttpError.new(double(status: 404)))
    expect(service.call(event_identifier: "corrida").not_found?).to be(true)
  end
end
