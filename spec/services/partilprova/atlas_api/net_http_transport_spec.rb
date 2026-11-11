require "rails_helper"

RSpec.describe Partilprova::AtlasApi::NetHttpTransport do
  it "maps network timeouts to the Atlas API timeout boundary" do
    allow(Net::HTTP).to receive(:start).and_raise(Net::ReadTimeout.new("timed out"))

    expect {
      described_class.new.get(
        uri: URI("https://atlas.example/api/public/v1/events"),
        headers: {},
        open_timeout: 2,
        read_timeout: 5
      )
    }.to raise_error(Partilprova::AtlasApi::TimeoutError, /timed out/)
  end

  it "maps connection failures to a transport error" do
    allow(Net::HTTP).to receive(:start).and_raise(Errno::ECONNREFUSED)

    expect {
      described_class.new.get(
        uri: URI("https://atlas.example/api/public/v1/events"),
        headers: {},
        open_timeout: 2,
        read_timeout: 5
      )
    }.to raise_error(Partilprova::AtlasApi::TransportError, /unreachable/)
  end
end
