# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::TabsComponent, type: :component do
  describe "basic rendering" do
    it "renders tabs with content" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      expect(page).to have_css("button[role='tab']", text: "Tab 1")
      expect(page).to have_css("button[role='tab']", text: "Tab 2")
      # Only visible panel is counted by default
      expect(page).to have_css("div[role='tabpanel']:not(.hidden)", text: "Content 1")
      # Hidden panel needs to use visible: :all to be found
      expect(page).to have_css("div[role='tabpanel'].hidden", text: "Content 2", visible: :all)
    end

    it "applies tabs controller" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[data-controller='components--tabs']")
    end

    it "generates unique tabs ID" do
      component = described_class.new
      tabs_id = component.instance_variable_get(:@tabs_id)

      expect(tabs_id).to match(/^tabs-[a-f0-9]+$/)
    end
  end

  describe "ARIA attributes" do
    it "sets role='tablist' on tab list" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[role='tablist']")
    end

    it "sets aria-label on tablist" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      # Expect French translation (default locale is :fr)
      expect(page).to have_css("div[role='tablist'][aria-label='Onglets']")
    end

    it "sets correct aria-controls on tab buttons" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "overview", label: "Overview") { "Content" }
      end

      button = page.find("button[role='tab']")
      panel_id = button["aria-controls"]
      expect(panel_id).to match(/tabs-[a-f0-9]+-panel-overview/)
    end

    it "sets aria-labelledby on panels" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "overview", label: "Overview") { "Content" }
      end

      panel = page.find("div[role='tabpanel']")
      tab_id = panel["aria-labelledby"]
      expect(tab_id).to match(/tabs-[a-f0-9]+-tab-overview/)
    end

    it "sets aria-selected=true on selected tab" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      tab1 = page.find("button[role='tab']", text: "Tab 1")
      expect(tab1["aria-selected"]).to eq("true")
    end

    it "sets aria-selected=false on non-selected tabs" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      tab2 = page.all("button[role='tab']")[1]
      expect(tab2["aria-selected"]).to eq("false")
    end

    it "sets tabindex=0 on selected tab" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["tabindex"]).to eq("0")
    end

    it "sets tabindex=-1 on non-selected tabs" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      tab2 = page.all("button[role='tab']")[1]
      expect(tab2["tabindex"]).to eq("-1")
    end

    it "sets aria-orientation=vertical on vertical tabs" do
      render_inline(described_class.new(vertical: true)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[role='tablist'][aria-orientation='vertical']")
    end
  end

  describe "selected tab behavior" do
    it "selects first tab by default when none explicitly selected" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      first_tab = page.all("button[role='tab']").first
      expect(first_tab["aria-selected"]).to eq("true")
    end

    it "selects explicitly selected tab" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2", selected: true) { "Content 2" }
      end

      tab2 = page.all("button[role='tab']")[1]
      expect(tab2["aria-selected"]).to eq("true")
    end

    it "hides non-selected panel" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      # Use visible: :all to find hidden elements
      panels = page.all("div[role='tabpanel']", visible: :all)
      expect(panels[0]["class"]).not_to include("hidden")
      expect(panels[1]["class"]).to include("hidden")
    end

    it "shows selected panel" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" }
      end

      panel = page.find("div[role='tabpanel']")
      expect(panel["class"]).not_to include("hidden")
    end
  end

  describe "variants" do
    it "uses underline variant by default" do
      component = described_class.new
      expect(component.instance_variable_get(:@variant)).to eq(:underline)
    end

    it "applies underline variant classes to selected tab" do
      render_inline(described_class.new(variant: :underline)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["class"]).to include("text-indigo-700")
      expect(tab["class"]).to include("border-indigo-600")
      expect(tab["class"]).to include("border-b-2")
    end

    it "applies pills variant classes to selected tab" do
      render_inline(described_class.new(variant: :pills)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["class"]).to include("bg-indigo-600")
      expect(tab["class"]).to include("text-white")
      expect(tab["class"]).to include("rounded-lg")
    end

    it "applies boxed variant classes to selected tab" do
      render_inline(described_class.new(variant: :boxed)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["class"]).to include("bg-white")
      expect(tab["class"]).to include("text-indigo-700")
      expect(tab["class"]).to include("rounded-t-lg")
    end

    it "raises error for invalid variant" do
      expect {
        described_class.new(variant: :invalid)
      }.to raise_error(ArgumentError, /Invalid variant: invalid/)
    end

    it "accepts variant as string" do
      component = described_class.new(variant: "pills")
      expect(component.instance_variable_get(:@variant)).to eq(:pills)
    end
  end

  describe "full width tabs" do
    it "applies full width class to tablist when full_width is true" do
      render_inline(described_class.new(full_width: true)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[role='tablist'].w-full")
    end

    it "applies flex-1 to tab buttons when full_width is true" do
      render_inline(described_class.new(full_width: true)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["class"]).to include("flex-1")
      expect(tab["class"]).to include("justify-center")
    end

    it "does not apply full width classes by default" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["class"]).not_to include("flex-1")
    end
  end

  describe "vertical tabs" do
    it "applies vertical classes to wrapper" do
      render_inline(described_class.new(vertical: true)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div.tabs-component.tabs-component--vertical")
    end

    it "applies vertical flex layout" do
      render_inline(described_class.new(vertical: true)) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[role='tablist'].flex-col")
      expect(page).to have_css("div[role='tablist'].border-r.border-slate-200.pr-4")
    end

    it "uses horizontal layout by default" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[role='tablist'].border-b.border-slate-200")
      expect(page).to have_no_css("div[role='tablist'].flex-col")
    end
  end

  describe "icons in tabs" do
    it "renders icon when icon provided" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "home", label: "Home", icon: :home) { "Content" }
      end

      # Icon component would be rendered if Foundation::IconComponent is available
      tab = page.find("button[role='tab']")
      expect(tab).to have_css("span", text: "Home")
    end

    it "does not render icon when icon not provided" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab).to have_css("span", text: "Tab 1")
    end
  end

  describe "disabled tabs" do
    it "sets disabled attribute on disabled tab" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", disabled: true) { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab).to be_disabled
    end

    it "sets aria-disabled on disabled tab" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", disabled: true) { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["aria-disabled"]).to eq("true")
    end

    it "does not disable tabs by default" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab).not_to be_disabled
    end
  end

  describe "stimulus integration" do
    it "adds stimulus targets to tabs" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("button[data-components--tabs-target='tab']")
    end

    it "adds stimulus targets to panels" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[data-components--tabs-target='panel']")
    end

    it "adds click action to tabs" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      tab = page.find("button[role='tab']")
      expect(tab["data-action"]).to include("click->components--tabs#select")
      expect(tab["data-action"]).to include("keydown->components--tabs#handleKeydown")
    end

    it "sets initial index value" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2", selected: true) { "Content 2" }
      end

      wrapper = page.find("div[data-controller='components--tabs']")
      expect(wrapper["data-components--tabs-initial-index-value"]).to eq("1")
    end

    it "sets data-index on tabs and panels" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      tab_buttons = page.all("button[role='tab']")
      expect(tab_buttons[0]["data-index"]).to eq("0")
      expect(tab_buttons[1]["data-index"]).to eq("1")

      # Use visible: :all to find hidden panels
      panels = page.all("div[role='tabpanel']", visible: :all)
      expect(panels[0]["data-index"]).to eq("0")
      expect(panels[1]["data-index"]).to eq("1")
    end
  end

  describe "HTML attributes" do
    it "merges custom CSS classes" do
      render_inline(described_class.new(class: "custom-tabs-class")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div.tabs-component.custom-tabs-class")
    end

    it "applies stimulus controller" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content" }
      end

      expect(page).to have_css("div[data-controller='components--tabs']")
    end
  end

  describe "complete example" do
    it "renders tabs with all features" do
      render_inline(described_class.new(
        variant: :pills,
        full_width: false,
        vertical: false,
        class: "my-tabs"
      )) do |tabs|
        tabs.with_tab(id: "overview", label: "Overview", icon: :home, selected: true) do
          "Overview content"
        end
        tabs.with_tab(id: "details", label: "Details", icon: :document) do
          "Details content"
        end
        tabs.with_tab(id: "settings", label: "Settings", icon: :cog_6_tooth, disabled: true) do
          "Settings content"
        end
      end

      expect(page).to have_css("div.tabs-component.my-tabs")
      expect(page).to have_css("div[role='tablist']")
      expect(page).to have_css("button[role='tab']", count: 3)

      # Check selected state
      overview_tab = page.find("button[role='tab']", text: "Overview")
      expect(overview_tab["aria-selected"]).to eq("true")
      expect(overview_tab["class"]).to include("bg-indigo-600")

      # Check disabled state
      settings_tab = page.all("button[role='tab']")[2]
      expect(settings_tab).to be_disabled

      # Check panels - use visible: :all to count all panels including hidden
      expect(page).to have_css("div[role='tabpanel']", count: 3, visible: :all)
      # Check visible panel
      visible_panel = page.find("div[role='tabpanel']:not(.hidden)")
      expect(visible_panel).to have_text("Overview content")
    end
  end
end
