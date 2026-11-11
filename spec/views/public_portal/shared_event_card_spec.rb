require "rails_helper"

RSpec.describe "PP-INTEGRATION.03.2 shared event cards", type: :view do
  let(:event) do
    { id: 42, slug: "maratona-natalina", name: "3ª Maratona Natalina 2026",
      city: "Palmas", state: "TO", modality: "Corrida de Rua",
      starts_at: Time.zone.parse("2026-12-17 07:00"), image_url: nil }
  end

  it "uses the same detail route for the event title and call to action" do
    render partial: "public_portal/events/card", locals: { event: event }
    expect(rendered).to include('/eventos/maratona-natalina')
    expect(rendered.scan('href="/eventos/maratona-natalina"').length).to eq(2)
    expect(rendered).to include("PartilProva")
  end

  it "falls back to the id when a slug is unavailable" do
    render partial: "public_portal/events/card", locals: { event: event.merge(slug: nil) }
    expect(rendered).to include('/eventos/42')
  end

  it "does not render unsafe image schemes" do
    render partial: "public_portal/events/card", locals: { event: event.merge(image_url: "javascript:alert(1)") }
    expect(rendered).to include("pp-catalog-card__placeholder")
    expect(rendered).not_to include("javascript:alert")
  end
end
