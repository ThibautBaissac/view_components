# frozen_string_literal: true

# Layout::EmptyStateComponent
#
# A reusable empty state component for displaying when no data is available.
# Includes optional icon, title, description, and action button.
#
# @example Basic empty state
#   <%= render Layout::EmptyStateComponent.new(
#     title: "No events yet",
#     description: "Get started by creating your first event"
#   ) %>
#
# @example With icon
#   <%= render Layout::EmptyStateComponent.new(
#     icon_name: "calendar",
#     title: "No events",
#     description: "Start by creating your first event"
#   ) %>
#
# @example With action button
#   <%= render Layout::EmptyStateComponent.new(
#     icon_name: "users",
#     title: "No vendors",
#     description: "Add your first vendor to get started"
#   ) do |empty_state| %>
#     <% empty_state.with_action do %>
#       <%= render Foundation::LinkComponent.new(
#         href: new_vendor_path,
#         text: "Add Vendor",
#         variant: :primary
#       ) %>
#     <% end %>
#   <% end %>
#
# @example Compact variant
#   <%= render Layout::EmptyStateComponent.new(
#     icon_name: "document",
#     title: "No notes",
#     compact: true
#   ) %>
#
class Layout::EmptyStateComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Slots
  renders_one :action

  # @param icon_name [String, nil] Heroicon name for the empty state icon
  # @param icon_variant [Symbol] Icon variant (:outline, :solid)
  # @param icon_size [Symbol] Icon size (:large, :xl, :xxl)
  # @param title [String, Symbol] Title text or i18n key for empty state
  # @param description [String, Symbol, nil] Optional description text or i18n key
  # @param compact [Boolean] Whether to use compact styling (less padding)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    icon_name: nil,
    icon_variant: :outline,
    icon_size: :xl,
    title:,
    description: nil,
    compact: false,
    **html_attributes
  )
    @icon_name = icon_name
    @icon_variant = icon_variant
    @icon_size = icon_size
    @title = title
    @description = description
    @compact = compact
    @html_attributes = html_attributes
  end

  private

  def container_classes
    classes = [
      "text-center",
      padding_classes,
      @html_attributes[:class]
    ].compact

    classes.join(" ")
  end

  def padding_classes
    @compact ? "py-8" : "py-12"
  end

  def title_classes
    @compact ? "text-sm font-medium text-slate-900" : "mt-2 text-sm font-medium text-slate-900"
  end

  def description_classes
    "mt-1 text-sm text-slate-600"
  end

  def action_container_classes
    "mt-6"
  end

  def merged_html_attributes
    @html_attributes.except(:class)
  end

  def show_icon?
    @icon_name.present?
  end

  def show_description?
    @description.present?
  end

  # Support both plain strings and i18n keys for title
  def title_text
    if @title.is_a?(Symbol)
      t_component("titles.#{@title}", default: @title.to_s.titleize)
    else
      @title
    end
  end

  # Support both plain strings and i18n keys for description
  def description_text
    return nil unless @description.present?

    if @description.is_a?(Symbol)
      t_component("descriptions.#{@description}", default: @description.to_s.humanize)
    else
      @description
    end
  end
end
