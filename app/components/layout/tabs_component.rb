# frozen_string_literal: true

# Layout::TabsComponent
#
# An accessible tabbed interface component that organizes content into multiple panels.
# Uses WAI-ARIA best practices for keyboard navigation and screen reader support.
# Integrates with Stimulus for interactive tab switching behavior.
#
# @example Basic usage
#   <%= render Layout::TabsComponent.new do |tabs| %>
#     <% tabs.with_tab(id: "overview", label: "Overview", selected: true) do %>
#       <p>Overview content here.</p>
#     <% end %>
#     <% tabs.with_tab(id: "details", label: "Details") do %>
#       <p>Details content here.</p>
#     <% end %>
#   <% end %>
#
# @example With icons
#   <%= render Layout::TabsComponent.new do |tabs| %>
#     <% tabs.with_tab(id: "home", label: "Home", icon: :home, selected: true) do %>
#       <p>Home content.</p>
#     <% end %>
#     <% tabs.with_tab(id: "settings", label: "Settings", icon: :cog_6_tooth) do %>
#       <p>Settings content.</p>
#     <% end %>
#   <% end %>
#
# @example Different variants
#   <%= render Layout::TabsComponent.new(variant: :pills) do |tabs| %>
#     <% tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content 1" } %>
#     <% tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" } %>
#   <% end %>
#
# @example Full width tabs
#   <%= render Layout::TabsComponent.new(full_width: true) do |tabs| %>
#     <% tabs.with_tab(id: "tab1", label: "Tab 1", selected: true) { "Content" } %>
#   <% end %>
#
class Layout::TabsComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available tab variants
  VARIANTS = %i[underline pills boxed].freeze

  # Default variant
  DEFAULT_VARIANT = :underline

  # Tab slot - each tab with its label and content
  renders_many :tabs, "TabComponent"

  # @param variant [Symbol] Visual style of tabs (:underline, :pills, :boxed)
  # @param full_width [Boolean] Whether tabs should stretch to fill available width
  # @param vertical [Boolean] Whether to display tabs vertically
  # @param html_attributes [Hash] Additional HTML attributes for the wrapper element
  def initialize(
    variant: DEFAULT_VARIANT,
    full_width: false,
    vertical: false,
    **html_attributes
  )
    @variant = variant.to_sym
    @full_width = full_width
    @vertical = vertical
    @html_attributes = html_attributes
    @tabs_id = "tabs-#{SecureRandom.hex(4)}"
    @aria_label = t_component("aria_label", default: "Tabs")

    validate_variant!
  end

  attr_reader :aria_label

  private

  def validate_variant!
    return if VARIANTS.include?(@variant)

    raise ArgumentError, "Invalid variant: #{@variant}. Valid variants are: #{VARIANTS.join(', ')}"
  end

  def merged_html_attributes
    defaults = {
      class: wrapper_classes,
      data: {
        controller: "components--tabs",
        "components--tabs-initial-index-value": selected_tab_index
      }
    }
    deep_merge_attributes(defaults, @html_attributes)
  end

  def wrapper_classes
    base = "tabs-component"
    classes = [ base ]
    classes << "tabs-component--vertical" if @vertical
    classes.compact.join(" ")
  end

  def tablist_classes
    base = %w[flex gap-1]

    if @vertical
      base << "flex-col"
      base << "border-r border-slate-200 pr-4"
    else
      base << "border-b border-slate-200"
    end

    base << "w-full" if @full_width && !@vertical

    base.join(" ")
  end

  def tab_button_classes(selected:)
    base = %w[
      inline-flex items-center gap-2
      font-medium text-sm
      transition-colors duration-200
      focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
    ]

    variant_classes = case @variant
    when :underline then underline_variant_classes(selected)
    when :pills then pills_variant_classes(selected)
    when :boxed then boxed_variant_classes(selected)
    end

    base.concat(variant_classes)
    base << "flex-1 justify-center" if @full_width

    base.join(" ")
  end

  def underline_variant_classes(selected)
    classes = %w[px-4 py-2.5]
    classes << "-mb-px" unless @vertical

    if selected
      classes.concat(%w[text-indigo-700 border-indigo-600 font-semibold])
      classes << (@vertical ? "border-r-2 -mr-px" : "border-b-2")
    else
      classes.concat(%w[text-slate-600 hover:text-slate-900 hover:border-slate-400])
      classes << (@vertical ? "border-r-2 border-transparent -mr-px" : "border-b-2 border-transparent")
    end

    classes
  end

  def pills_variant_classes(selected)
    classes = %w[px-4 py-2.5 rounded-lg]

    if selected
      classes.concat(%w[bg-indigo-600 text-white font-semibold shadow-md shadow-indigo-500/30])
    else
      classes.concat(%w[text-slate-600 hover:text-slate-900 hover:bg-slate-100])
    end

    classes
  end

  def boxed_variant_classes(selected)
    classes = %w[px-4 py-2.5 rounded-t-lg]

    if selected
      classes.concat(%w[bg-white text-indigo-700 font-semibold border border-slate-300 shadow-sm])
      classes << (@vertical ? "border-r-0" : "border-b-white -mb-px")
    else
      classes.concat(%w[text-slate-600 hover:text-slate-900 bg-slate-50 border border-transparent hover:bg-slate-100])
    end

    classes
  end

  def panel_classes(selected:)
    base = %w[tabs-panel p-5]
    base << "hidden" unless selected
    base.join(" ")
  end

  def panels_wrapper_classes
    base = %w[tabs-panels]
    base << "flex-1" if @vertical
    base.join(" ")
  end

  def content_wrapper_classes
    return "flex gap-4" if @vertical

    ""
  end

  # Returns the index of the initially selected tab
  def selected_tab_index
    tabs.each_with_index do |tab, index|
      return index if tab.selected?
    end
    0 # Default to first tab if none selected
  end

  # Checks if a tab at a given index should be visually selected
  # This handles the case where no tab is explicitly selected (defaults to first)
  def tab_selected?(tab, index)
    return tab.selected? if any_tab_selected?

    index == 0 # Default to first tab
  end

  # Checks if any tab is explicitly marked as selected
  def any_tab_selected?
    tabs.any?(&:selected?)
  end

  # Inner component for individual tabs
  class TabComponent < ViewComponent::Base
    # @param id [String] Unique identifier for the tab
    # @param label [String] Text label for the tab button
    # @param icon [Symbol, nil] Optional icon name for the tab
    # @param selected [Boolean] Whether this tab is initially selected
    # @param disabled [Boolean] Whether this tab is disabled
    def initialize(id:, label:, icon: nil, selected: false, disabled: false)
      @id = id
      @label = label
      @icon = icon
      @selected = selected
      @disabled = disabled
    end

    attr_reader :id, :label, :icon, :disabled

    def selected?
      @selected
    end

    def disabled?
      @disabled
    end

    def call
      content
    end
  end
end
