require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoGalleryFilterContract do
  it "rejects filters while Atlas has not been qualified" do
    expect { described_class.build(album_id: "album-1", enabled: false) }.to raise_error(described_class::InvalidQuery)
    expect(described_class.build(enabled: false).public_params).to eq({})
  end

  it "preserves opaque public identifiers and rejects unsafe values" do
    query = described_class.build(album_id: "0007", session_id: "session-2", enabled: true)
    expect(query.public_params).to eq(album_id: "0007", session_id: "session-2")
    expect { described_class.build(album_id: "../../secret", enabled: true) }.to raise_error(described_class::InvalidQuery)
    expect { described_class.build(session_id: ["1"], enabled: true) }.to raise_error(described_class::InvalidQuery)
  end

  it "only accepts explicitly supplied public filter choices" do
    options = described_class.options("photo_filter_options" => {
      "albums" => [{ "id" => "album-1", "name" => "Largada" }, { "id" => "bad/id", "name" => "Privado" }],
      "sessions" => [{ "id" => "session-2", "name" => "Chegada" }]
    })
    expect(options).to eq(albums: [["Largada", "album-1"]], sessions: [["Chegada", "session-2"]])
  end
end
