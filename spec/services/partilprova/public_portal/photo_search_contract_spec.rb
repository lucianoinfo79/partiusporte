require "rails_helper"

RSpec.describe Partilprova::PublicPortal::PhotoSearchContract do
  describe ".build" do
    it "normalizes the event-scoped public query" do
      query = described_class.build(event_identifier: "corrida-2026", bib_number: " 009001 ", page: "2")
      expect(query.event_identifier).to eq("corrida-2026")
      expect(query.bib_number).to eq("009001")
      expect(query.public_params).to eq(page: 2, per_page: 24, bib_number: "009001")
    end

    it "supports browsing without a bib number" do
      query = described_class.build(event_identifier: "corrida")
      expect(query.filtered?).to eq(false)
      expect(query.public_params).to eq(page: 1, per_page: 24)
    end

    it "rejects malformed or excessively long bib numbers" do
      ["1 OR 1=1", "12/34", "1234567890123", [], {}].each do |value|
        expect { described_class.build(event_identifier: "corrida", bib_number: value) }
          .to raise_error(described_class::InvalidQuery)
      end
    end

    it "rejects unsafe event identifiers and pages" do
      ["../private", "a/b", ""].each do |event|
        expect { described_class.build(event_identifier: event) }.to raise_error(described_class::InvalidQuery)
      end
      ["0", "1001", "abc", "1.5"].each do |page|
        expect { described_class.build(event_identifier: "corrida", page: page) }
          .to raise_error(described_class::InvalidQuery)
      end
    end
  end
end
