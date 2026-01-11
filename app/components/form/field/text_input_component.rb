# frozen_string_literal: true

# Form::Field::TextInputComponent
#
# A flexible text input component that wraps a standard HTML input element
# with consistent styling, labels, hints, and error handling.
#
# @example Basic usage
#   <%= render Form::Field::TextInputComponent.new(name: "email") %>
#
# @example With label
#   <%= render Form::Field::TextInputComponent.new(
#     name: "email",
#     label: "Email Address"
#   ) %>
#
# @example With placeholder and hint
#   <%= render Form::Field::TextInputComponent.new(
#     name: "email",
#     label: "Email Address",
#     placeholder: "you@example.com",
#     hint: "We'll never share your email with anyone."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::TextInputComponent.new(
#     name: "email",
#     label: "Email",
#     error: "is invalid"
#   ) %>
#
# @example Different input types
#   <%= render Form::Field::TextInputComponent.new(name: "phone", type: :tel) %>
#   <%= render Form::Field::TextInputComponent.new(name: "website", type: :url) %>
#   <%= render Form::Field::TextInputComponent.new(name: "search", type: :search) %>
#
# @example Required field
#   <%= render Form::Field::TextInputComponent.new(
#     name: "username",
#     label: "Username",
#     required: true
#   ) %>
#
# @example With leading and trailing icons
#   <%= render Form::Field::TextInputComponent.new(name: "email") do |input| %>
#     <% input.with_icon_leading do %>
#       <%= render Foundation::IconComponent.new(name: "envelope") %>
#     <% end %>
#   <% end %>
#
# @example With pattern validation
#   <%= render Form::Field::TextInputComponent.new(
#     name: "zip_code",
#     label: "ZIP Code",
#     pattern: "[0-9]{5}",
#     title: "Five digit ZIP code"
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::TextInputComponent.new(
#     name: "readonly_field",
#     value: "Cannot edit",
#     disabled: true
#   ) %>
#
class Form::Field::TextInputComponent < Form::Field::BaseComponent
  # Available input types
  TYPES = %i[text email tel url search number].freeze

  # Default input type
  DEFAULT_TYPE = :text

  # Slots for icons
  renders_one :icon_leading
  renders_one :icon_trailing

  # @param name [String] The input name attribute (required)
  # @param id [String] The input id attribute (defaults to name)
  # @param type [Symbol] The input type (:text, :email, :tel, :url, :search, :number)
  # @param value [String] The input value
  # @param label [String] The label text
  # @param placeholder [String] The placeholder text
  # @param hint [String] Help text displayed below the input
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly
  # @param size [Symbol] The input size (:small, :medium, :large)
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    type: DEFAULT_TYPE,
    **options
  )
    super(name: name, **options)
    @type = type.to_sym
    validate_type!
  end

  private

  def validate_type!
    return if TYPES.include?(@type)

    raise ArgumentError, "Invalid type: #{@type}. Valid types are: #{TYPES.join(', ')}"
  end

  # Wrapper div needs relative positioning for absolutely positioned icons
  # @return [String]
  def input_wrapper_classes
    "relative"
  end

  def input_classes
    classes = [
      base_field_classes,
      size_field_classes,
      state_field_classes
    ]
    classes << "pl-10" if icon_leading?
    classes << "pr-10" if icon_trailing?
    classes << @html_attributes[:class] if @html_attributes[:class]
    classes.compact.join(" ")
  end

  # Icon wrapper classes with absolute positioning
  # @param position [Symbol] :leading or :trailing
  # @return [String]
  def icon_wrapper_classes(position)
    base = "absolute inset-y-0 flex items-center pointer-events-none"
    case position
    when :leading
      "#{base} left-0 pl-3"
    when :trailing
      "#{base} right-0 pr-3"
    end
  end

  # Icon color based on error state
  # @return [String]
  def icon_color_classes
    has_error? ? "text-red-400" : "text-slate-400"
  end

  def input_attributes
    attrs = base_field_attributes.merge(
      type: @type,
      value: @value,
      "aria-required": @required ? "true" : nil
    )
    merge_html_attributes(attrs)
  end

  def merged_input_attributes
    input_attributes.merge(class: input_classes)
  end
end
