require "rails_helper"

RSpec.describe "PP05.1 — Photo search contract qualification" do
  it "keeps search disabled until Atlas confirms its public filtered contract" do
    capability = Partilprova::PublicPortal::PhotoSearchCapability.current
    expect(capability.available?).to eq(false)
    expect(capability.reason).to eq(:atlas_contract_pending)
  end

  it "does not change the existing public gallery catalog interface" do
    parameters = Partilprova::PublicPortal::PhotoCatalog.instance_method(:call).parameters
    expect(parameters).to include([:keyreq, :event_identifier], [:key, :page])
  end

  it "does not put participant identity or private storage into public search params" do
    query = Partilprova::PublicPortal::PhotoSearchContract.build(event_identifier: "prova", bib_number: "9001")
    expect(query.public_params.keys).to match_array(%i[page per_page bib_number])
  end
end
