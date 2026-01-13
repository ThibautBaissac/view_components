# frozen_string_literal: true

# Layout::ModalComponent
#
# A flexible modal dialog component that displays content in an overlay.
# Supports different sizes, dismissible behavior, and integrates with Turbo.
# Uses the native HTML <dialog> element for accessibility.
#
# @example Basic modal
#   <%= render Layout::ModalComponent.new(id: "my-modal", title: "Modal Title") do %>
#     <p>Modal content goes here.</p>
#   <% end %>
#
# @example Large modal with slots
#   <%= render Layout::ModalComponent.new(id: "large-modal", size: :large) do |modal| %>
#     <% modal.with_header { "Custom Header" } %>
#     <% modal.with_body do %>
#       <p>Body content here.</p>
#     <% end %>
#     <% modal.with_footer do %>
#       <button>Action</button>
#     <% end %>
#   <% end %>
#
# @example Non-dismissible modal
#   <%= render Layout::ModalComponent.new(id: "required-modal", dismissible: false) do %>
#     <p>You must complete this action.</p>
#   <% end %>
#
# @example Modal open by default (useful with Turbo)
#   <%= render Layout::ModalComponent.new(id: "open-modal", open: true) do %>
#     <p>This modal opens automatically.</p>
#   <% end %>
#
class Layout::ModalComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available modal sizes
  SIZES = %i[small medium large full].freeze

  # Default size
  DEFAULT_SIZE = :medium

  # Size configurations with max-width classes
  SIZE_CONFIG = {
    small: "max-w-sm",
    medium: "max-w-lg",
    large: "max-w-2xl",
    full: "max-w-4xl"
  }.freeze

  # Slots
  renders_one :header
  renders_one :body
  renders_one :footer
  renders_one :close_button

  # @param id [String] Unique ID for the modal (required)
  # @param title [String, nil] Optional title displayed in header
  # @param size [Symbol] Modal size (:small, :medium, :large, :full)
  # @param dismissible [Boolean] Whether modal can be dismissed (ESC key, backdrop click, close button).
  #   When true, clicking outside the modal panel or pressing ESC will close the modal.
  #   When false, the modal can only be closed programmatically or via explicit close actions.
  # @param open [Boolean] Whether the modal should be open by default
  # @param close_on_submit [Boolean] Whether to close modal after successful form submission
  # @param html_attributes [Hash] Additional HTML attributes for the dialog element
  def initialize(
    id:,
    title: nil,
    size: DEFAULT_SIZE,
    dismissible: true,
    open: false,
    close_on_submit: true,
    **html_attributes
  )
    @id = id
    @title = title
    @size = size.to_sym
    @dismissible = dismissible
    @open = open
    @close_on_submit = close_on_submit
    @html_attributes = html_attributes

    validate_size!
  end

  # Modal trigger button helper for use outside the component
  # Returns data attributes for a trigger button
  #
  # When used with html_attributes parameter:
  #   html_attributes: Layout::ModalComponent.trigger_attributes(modal_id: "my-modal")
  #
  # When used with data parameter or helpers.tag.attributes:
  #   data: Layout::ModalComponent.trigger_data(modal_id: "my-modal")
  #
  # @return [Hash] HTML attributes with nested data hash
  def self.trigger_attributes(modal_id:)
    {
      data: trigger_data(modal_id: modal_id)
    }
  end

  # Returns just the data attributes hash for trigger buttons
  # @return [Hash] Data attributes hash
  def self.trigger_data(modal_id:)
    {
      controller: "components--modal",
      action: "click->components--modal#triggerOpen",
      modal_target: modal_id
    }
  end

  private

  def validate_size!
    return if SIZES.include?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Must be one of #{SIZES.join(', ')}"
  end

  def dialog_classes
    classes = [
      "modal",
      "fixed inset-0 z-50 m-auto",
      "w-full",
      SIZE_CONFIG[@size],
      "p-0 bg-transparent",
      "backdrop:bg-slate-900/60 backdrop:backdrop-blur-md",
      "open:animate-modal-enter"
    ]

    classes.join(" ")
  end

  def panel_classes
    [
      "modal-panel",
      "bg-white rounded-2xl shadow-2xl",
      "flex flex-col max-h-[calc(100vh-4rem)]",
      "transform transition-all"
    ].join(" ")
  end

  def header_classes
    "modal-header flex items-center justify-between px-6 py-5 border-b border-slate-200"
  end

  def title_classes
    "text-xl font-bold text-slate-900"
  end

  def body_classes
    "modal-body flex-1 overflow-y-auto px-6 py-5"
  end

  def footer_classes
    "modal-footer flex items-center justify-end gap-3 px-6 py-5 border-t border-slate-200 bg-slate-50/50"
  end

  def close_button_classes
    "flex-shrink-0 -mr-2 text-gray-400 hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-lg"
  end

  def controller_data
    data = {
      controller: "components--modal",
      components__modal_dismissible_value: @dismissible,
      components__modal_close_on_submit_value: @close_on_submit
    }

    if @open
      data[:components__modal_open_value] = true
    end

    { data: data }
  end

  def merged_html_attributes
    default_attrs = controller_data.merge(id: @id)

    # Use deep_merge_attributes from concern with special handling for controller concatenation
    merged = deep_merge_attributes(default_attrs, @html_attributes)

    # Concatenate controllers instead of replacing (required for Stimulus multi-controller support)
    if @html_attributes.dig(:data, :controller).present?
      base_controller = controller_data.dig(:data, :controller)
      user_controller = @html_attributes.dig(:data, :controller)
      merged[:data][:controller] = "#{base_controller} #{user_controller}"
    end

    merged
  end

  def show_header?
    @title.present? || header?
  end

  def show_default_title?
    @title.present? && !header?
  end

  def show_close_button?
    @dismissible
  end

  def show_footer?
    footer?
  end

  def has_slots?
    header? || body? || footer?
  end

  def close_button_aria_label
    t_component("close_button_aria_label", default: "Close modal")
  end
end
