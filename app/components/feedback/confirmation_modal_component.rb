# frozen_string_literal: true

# Feedback::ConfirmationModalComponent
#
# A specialized confirmation modal for destructive or important actions.
# Provides a consistent UX for confirmations with appropriate styling,
# icons, and action buttons.
#
# @example Basic delete confirmation
#   <%= render Feedback::ConfirmationModalComponent.new(
#     id: "delete-confirm",
#     title: "Delete Item",
#     message: "Are you sure you want to delete this item? This action cannot be undone.",
#     confirm_text: "Delete",
#     confirm_url: item_path(@item),
#     confirm_method: :delete,
#     type: :danger
#   ) %>
#
# @example Warning confirmation
#   <%= render Feedback::ConfirmationModalComponent.new(
#     id: "publish-confirm",
#     title: "Publish Article",
#     message: "Publishing will make this article visible to all users.",
#     confirm_text: "Publish",
#     confirm_url: publish_article_path(@article),
#     confirm_method: :post,
#     type: :warning
#   ) %>
#
# @example Info confirmation with form
#   <%= render Feedback::ConfirmationModalComponent.new(
#     id: "submit-confirm",
#     title: "Submit Application",
#     message: "Once submitted, you cannot edit your application.",
#     confirm_text: "Submit",
#     type: :info
#   ) do |modal| %>
#     <% modal.with_form do %>
#       <%= form_with url: submit_path, method: :post do |f| %>
#         <%= f.submit "Submit Application", class: "btn btn-primary" %>
#       <% end %>
#     <% end %>
#   <% end %>
#
class Feedback::ConfirmationModalComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available confirmation types
  TYPES = %i[danger warning info].freeze

  # Default type
  DEFAULT_TYPE = :danger

  # Type configurations with colors, icons, and styles
  TYPE_CONFIG = {
    danger: {
      icon_name: "exclamation-triangle",
      icon_color: :danger,
      icon_bg: "bg-red-100",
      confirm_variant: :danger
    },
    warning: {
      icon_name: "exclamation-triangle",
      icon_color: :warning,
      icon_bg: "bg-yellow-100",
      confirm_variant: :warning
    },
    info: {
      icon_name: "information-circle",
      icon_color: :info,
      icon_bg: "bg-sky-100",
      confirm_variant: :primary
    }
  }.freeze

  # Slots
  renders_one :icon, Foundation::IconComponent
  renders_one :description
  renders_one :form

  # @param id [String] Unique ID for the modal (required)
  # @param title [String] The confirmation title (required)
  # @param message [String] The confirmation message (required)
  # @param type [Symbol] Confirmation type (:danger, :warning, :info)
  # @param confirm_text [String] Text for the confirm button (default: I18n translated)
  # @param cancel_text [String] Text for the cancel button (default: I18n translated)
  # @param confirm_url [String, nil] URL for the confirm action (creates a link/form)
  # @param confirm_method [Symbol] HTTP method for confirm action (:get, :post, :patch, :put, :delete)
  # @param show_icon [Boolean] Whether to show the type icon (default: true)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    id:,
    title:,
    message:,
    type: DEFAULT_TYPE,
    confirm_text: nil,
    cancel_text: nil,
    confirm_url: nil,
    confirm_method: :post,
    show_icon: true,
    **html_attributes
  )
    @id = id
    @title = title
    @message = message
    @type = type.to_sym
    @confirm_text = confirm_text || t_component("confirm", default: "Confirm")
    @cancel_text = cancel_text || t_component("cancel", default: "Cancel")
    @confirm_url = confirm_url
    @confirm_method = confirm_method
    @show_icon = show_icon
    @html_attributes = html_attributes

    validate_type!
  end

  # Trigger button helper for use outside the component
  # @return [Hash] Data attributes for a trigger button
  def self.trigger_attributes(modal_id:)
    Layout::ModalComponent.trigger_attributes(modal_id: modal_id)
  end

  private

  def validate_type!
    return if TYPES.include?(@type)

    raise ArgumentError, "Invalid type: #{@type}. Must be one of #{TYPES.join(', ')}"
  end

  def type_config
    TYPE_CONFIG[@type]
  end

  def icon_container_classes
    [
      "mx-auto flex items-center justify-center h-12 w-12 rounded-full",
      type_config[:icon_bg]
    ].join(" ")
  end

  def title_classes
    "text-lg font-semibold text-slate-900 text-center"
  end

  def message_classes
    "text-sm text-slate-600 text-center"
  end

  def description_classes
    "text-sm text-slate-500 text-center mt-2"
  end

  def actions_classes
    "flex flex-col-reverse sm:flex-row sm:justify-center gap-3 mt-6"
  end

  def confirm_button_variant
    type_config[:confirm_variant]
  end

  def default_icon
    Foundation::IconComponent.new(
      name: type_config[:icon_name],
      color: type_config[:icon_color],
      size: :large,
      variant: :outline
    )
  end

  def show_icon?
    @show_icon && !icon?
  end

  def show_custom_icon?
    icon?
  end

  def confirm_url?
    @confirm_url.present?
  end

  def form_slot?
    form?
  end

  def confirm_link_data
    data = { turbo_method: @confirm_method }
    data[:action] = "click->components--modal#close" unless @confirm_method == :get
    data
  end

  def cancel_button_data
    { action: "click->components--modal#close" }
  end

  def controller_data
    {
      data: {
        controller: "components--confirmation-modal",
        action: "keydown.enter->components--confirmation-modal#confirmOnEnter"
      }
    }
  end

  def modal_html_attributes
    default_attrs = controller_data
    attrs = @html_attributes.except(:class)

    # Add ARIA attributes for accessibility
    attrs[:role] = "dialog"
    attrs[:aria] ||= {}
    attrs[:aria][:modal] = "true"
    attrs[:aria][:describedby] = "#{@id}-message"

    default_attrs.deep_merge(attrs)
  end

  def computed_classes
    custom_class = @html_attributes[:class]
    [ custom_class ].compact.join(" ")
  end

  def message_id
    "#{@id}-message"
  end
end
