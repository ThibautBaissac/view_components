# frozen_string_literal: true

require "rails_helper"

RSpec.describe Settings::PublicPageFormComponent, type: :component do
  let(:account) { create(:account) }
  let(:config) do
    create(:public_page_config,
      account: account,
      slug: "mon-mariage",
      title: "Organisez votre mariage",
      description: "Contactez-nous pour votre mariage de rêve",
      logo_url: "https://example.com/logo.png",
      primary_color: "#8B5CF6",
      confirmation_message: "Merci !",
      enabled: true,
      show_phone: true,
      show_event_date: true,
      show_budget: true,
      show_message: true)
  end
  let(:url) { "/settings/public_page" }

  it "renders the component" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_selector("form")
  end

  it "includes text input for slug" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[slug]", with: "mon-mariage")
  end

  it "includes text input for title" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[title]", with: "Organisez votre mariage")
  end

  it "includes textarea for description" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[description]")
  end

  it "includes text input for logo_url" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[logo_url]", with: "https://example.com/logo.png")
  end

  it "includes text input for primary_color" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[primary_color]", with: "#8B5CF6")
  end

  it "includes textarea for confirmation_message" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[confirmation_message]")
  end

  it "includes switch for enabled" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[enabled]", type: :checkbox)
  end

  it "includes switch for show_phone" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[show_phone]", type: :checkbox)
  end

  it "includes switch for show_event_date" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[show_event_date]", type: :checkbox)
  end

  it "includes switch for show_budget" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[show_budget]", type: :checkbox)
  end

  it "includes switch for show_message" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_field("public_page_config[show_message]", type: :checkbox)
  end

  it "uses form_with with provided URL" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_selector("form[action='#{url}']")
  end

  it "displays public page URL preview" do
    render_inline(described_class.new(config: config, url: url))

    expect(page).to have_content("/p/mon-mariage")
  end
end
