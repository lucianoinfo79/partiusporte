require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PublicationVisibility do
  it "rejects explicit unpublished and private records" do
    expect(described_class.visible?({ "id" => 1, "published" => false })).to eq(false)
    expect(described_class.visible?({ "id" => 1, "publicly_visible" => false })).to eq(false)
    %w[draft unpublished private hidden suspended archived].each do |state|
      expect(described_class.visible?({ "id" => 1, "publication_status" => state })).to eq(false)
    end
  end

  it "allows explicit published records" do
    expect(described_class.visible?({ "id" => 1, "published" => true, "publication_status" => "published" })).to eq(true)
  end

  it "does not confuse registration status with publication status" do
    expect(described_class.visible?({ "id" => 1, "published" => true, "registration_status" => "closed" })).to eq(true)
  end

  it "keeps legacy payloads compatible until Atlas provides an authoritative contract" do
    expect(described_class.visible?({ "id" => 1, "name" => "Prova" })).to eq(true)
  end
end
