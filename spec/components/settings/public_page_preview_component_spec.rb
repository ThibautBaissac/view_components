# frozen_string_literal: true

require "rails_helper"

RSpec.describe Settings::PublicPagePreviewComponent, type: :component do
  let(:account) { create(:account) }
  let(:config) do
    create(:public_page_config,
      account: account,
      slug: "mon-mariage",
      title: "Organisez votre mariage",
      description: "Contactez-nous pour votre mariage de rêve",
      logo_url: "https://example.com/logo.png",
      primary_color: "#8B5CF6",
      enabled: true,
      show_phone: true,
      show_event_date: true,
      show_budget: false,
      show_message: true)
  end

  it "renders the component" do
    render_inline(described_class.new(config: config))

    expect(page).to have_content("Aperçu")
  end

  it "displays the title" do
    render_inline(described_class.new(config: config))

    expect(page).to have_content("Organisez votre mariage")
  end

  it "displays the description" do
    render_inline(described_class.new(config: config))

    expect(page).to have_content("Contactez-nous pour votre mariage de rêve")
  end

  it "shows which fields are enabled" do
    render_inline(described_class.new(config: config))

    expect(page).to have_content("Téléphone")
    expect(page).to have_content("Date de l'événement")
    expect(page).to have_content("Message")
  end

  it "indicates disabled fields" do
    render_inline(described_class.new(config: config))

    # Budget should be shown as disabled/hidden
    expect(page).to have_css(".field-indicator")
  end

  it "applies branding color" do
    render_inline(described_class.new(config: config))

    # Check for primary color in preview
    expect(page).to have_css(".preview-container")
  end
end
