require "rails_helper"

RSpec.describe "PP02.11 qualification" do
  it "loads the public API client and exposes instrumentation" do
    expect(Partilprova::AtlasApi::Client.instance_methods(false)).to include(:get)
    expect(ActiveSupport::Notifications).to respond_to(:subscribe)
  end
end
