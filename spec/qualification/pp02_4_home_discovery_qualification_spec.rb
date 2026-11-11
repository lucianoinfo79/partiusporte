require "rails_helper"

RSpec.describe "PP02.4 Home / Descobrir Provas qualification", type: :request do
  it "keeps the home available when Atlas cannot be reached" do
    allow_any_instance_of(Partilprova::AtlasApi::Client).to receive(:get).and_raise(Partilprova::AtlasApi::TransportError, "offline")
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Agenda temporariamente indisponível")
  end

  it "keeps the PP02.2 public shell around the functional home" do
    allow_any_instance_of(Partilprova::PublicPortal::HomeDiscovery).to receive(:call).and_return(
      Partilprova::PublicPortal::HomeDiscovery::Result.new(events: [], modalities: Partilprova::PublicPortal::HomeDiscovery::DEFAULT_MODALITIES, available: true, query: "", modality: "")
    )
    get root_path
    expect(response.body).to include('data-public-shell="header"', "pp-footer", 'data-pp02-4="home-discovery"')
  end
end
