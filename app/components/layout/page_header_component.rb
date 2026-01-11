# frozen_string_literal: true

# Layout::PageHeaderComponent
#
# A reusable page header component with title, optional description/subtitle,
# optional badges, breadcrumb/back link, and action buttons.
#
# @example Simple header
#   <%= render Layout::PageHeaderComponent.new(title: "Events") %>
#
# @example With description
#   <%= render Layout::PageHeaderComponent.new(
#     title: "Events",
#     description: "Manage your events and weddings"
#   ) %>
#
# @example With badge
#   <%= render Layout::PageHeaderComponent.new(title: "John & Jane") do |header| %>
#     <% header.with_badge do %>
#       <%= render Display::BadgeComponent.new(text: "Confirmed", color: :success) %>
#     <% end %>
#   <% end %>
#
# @example With back link
#   <%= render Layout::PageHeaderComponent.new(
#     title: "Event Details",
#     back_url: events_path,
#     back_text: "← Back to events"
#   ) %>
#
# @example With action button
#   <%= render Layout::PageHeaderComponent.new(title: "Events") do |header| %>
#     <% header.with_action do %>
#       <%= render Foundation::LinkComponent.new(
#         href: new_event_path,
#         text: "New Event",
#         variant: :primary
#       ) %>
#     <% end %>
#   <% end %>
#
# @example Full featured
#   <%= render Layout::PageHeaderComponent.new(
#     title: "John & Jane Smith",
#     back_url: events_path,
#     back_text: "← Back to list"
#   ) do |header| %>
#     <% header.with_badge do %>
#       <%= render Display::BadgeComponent.new(text: "Confirmed", color: :success) %>
#     <% end %>
#     <% header.with_action do %>
#       <%= render Foundation::LinkComponent.new(
#         href: edit_event_path(@event),
#         text: "Edit",
#         variant: :primary
#       ) %>
#     <% end %>
#   <% end %>
#
class Layout::PageHeaderComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Slots
  renders_one :badge
  renders_one :action

  # @param title [String] Page title
  # @param description [String, nil] Optional description/subtitle
  # @param back_url [String, nil] Optional back/breadcrumb URL
  # @param back_text [String, nil] Text for back link (uses I18n default if not provided)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    title:,
    description: nil,
    back_url: nil,
    back_text: nil,
    **html_attributes
  )
    @title = title
    @description = description
    @back_url = back_url
    @back_text = back_text
    @html_attributes = html_attributes
  end

  private

  def container_classes
    "mb-6"
  end

  def merged_html_attributes
    deep_merge_attributes(
      { class: container_classes },
      @html_attributes
    )
  end

  def title_container_classes
    "flex items-center gap-3 mb-2"
  end

  def title_classes
    [
      "text-2xl font-light",
      "md:text-3xl",
      "text-slate-900"
    ].join(" ")
  end

  def description_classes
    [
      "mt-1",
      "text-sm md:text-base",
      "text-slate-600"
    ].join(" ")
  end

  def action_container_classes
    [
      "flex",
      "flex-col gap-4",
      "md:flex-row md:justify-between md:items-center"
    ].join(" ")
  end

  def back_link_container_classes
    "flex gap-2 mt-4"
  end

  def show_description?
    @description.present?
  end

  def show_back_link?
    @back_url.present?
  end

  def show_action_container?
    action? && !show_back_link?
  end

  # I18n helpers
  def back_link_text
    @back_text || t_component("back_link", default: "← Retour à la liste")
  end

  def back_link_aria_label
    t_component("back_link_label", default: "Retourner à la page précédente")
  end

  def breadcrumb_aria_label
    t_component("breadcrumb", default: "Fil d'ariane")
  end

  def badge_aria_label
    t_component("badge_label", default: "Statut")
  end

  def actions_aria_label
    t_component("actions_label", default: "Actions de la page")
  end

  def description_id
    "#{@title.parameterize}-description" if show_description?
  end
end
