# frozen_string_literal: true

# Form::Field::SwitchComponent
#
# A toggle switch component that provides a visual alternative to checkboxes
# for binary on/off settings. Provides consistent styling, labels, hints,
# error handling, and accessibility features.
#
# When to Use Switch vs Checkbox:
# - Use Switch for instant-effect settings (dark mode, notifications, feature toggles)
# - Use Checkbox for selections that require form submission (terms acceptance, multi-select)
# - Use Switch when the action is immediate and doesn't need confirmation
# - Use Checkbox when multiple items can be selected from a list
#
# Hidden Field Behavior:
#   By default, a hidden field with value "0" is included before the switch.
#   This ensures Rails receives a value when the switch is off.
#   Without it, switches that are off don't submit any value.
#   Set include_hidden: false when using switches in arrays or when
#   you need different off behavior.
#
# Accessibility:
#   The switch uses a checkbox input as its underlying control, ensuring
#   proper keyboard navigation and screen reader support. The visual toggle
#   is purely decorative.
#
# @example Basic usage
#   <%= render Form::Field::SwitchComponent.new(name: "notifications") %>
#
# @example With label
#   <%= render Form::Field::SwitchComponent.new(
#     name: "dark_mode",
#     label: "Enable dark mode"
#   ) %>
#
# @example Checked by default
#   <%= render Form::Field::SwitchComponent.new(
#     name: "notifications",
#     label: "Push notifications",
#     checked: true
#   ) %>
#
# @example With custom value
#   <%= render Form::Field::SwitchComponent.new(
#     name: "preference",
#     label: "Enable feature",
#     value: "feature_enabled"
#   ) %>
#
# @example With hint
#   <%= render Form::Field::SwitchComponent.new(
#     name: "marketing",
#     label: "Marketing emails",
#     hint: "Receive promotional content and offers."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::SwitchComponent.new(
#     name: "terms",
#     label: "Accept terms",
#     error: "must be accepted"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::SwitchComponent.new(
#     name: "terms",
#     label: "I accept the terms",
#     required: true
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::SwitchComponent.new(
#     name: "locked_feature",
#     label: "Premium feature",
#     checked: true,
#     disabled: true
#   ) %>
#
# @example With label slot for custom content
#   <%= render Form::Field::SwitchComponent.new(name: "terms") do |switch| %>
#     <% switch.with_label_content do %>
#       I agree to the <a href="/terms" class="text-blue-600 underline">terms and conditions</a>
#     <% end %>
#   <% end %>
#
# @example With Stimulus controller for enhanced interactions
#   <div data-controller="components--switch"
#        data-action="change->components--switch#toggle"
#        data-components--switch-confirm-value="Are you sure you want to disable this feature?">
#     <%= render Form::Field::SwitchComponent.new(
#       name: "critical_feature",
#       label: "Enable critical feature"
#     ) %>
#   </div>
#
class Form::Field::SwitchComponent < Form::Field::BaseComponent
  # Slot for custom label content (allows HTML like links)
  renders_one :label_content

  # @param name [String] The input name attribute (required)
  # @param id [String] The input id attribute (defaults to name)
  # @param value [String] The value when checked (defaults to "1")
  # @param checked [Boolean] Whether the switch is on
  # @param label [String] The label text
  # @param hint [String] Help text displayed below the switch
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param size [Symbol] The switch size (:small, :medium, :large)
  # @param include_hidden [Boolean] Whether to include a hidden field for off value
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    value: "1",
    checked: false,
    include_hidden: true,
    **options
  )
    # Remove placeholder and readonly as they don't apply to switches
    options.delete(:placeholder)
    options.delete(:readonly)
    super(name: name, value: value, **options)
    @checked = checked
    @include_hidden = include_hidden
  end

  # Whether the switch is on
  # @return [Boolean]
  def checked?
    @checked
  end

  # Whether to include the hidden field
  # @return [Boolean]
  def include_hidden?
    @include_hidden
  end

  # Whether the label should be rendered (either via prop or slot)
  # Overrides parent method to include label_content slot detection
  # @return [Boolean] true if label prop or label_content slot is provided
  def has_label?
    @label.present? || label_content?
  end

  private

  # CSS classes for the field wrapper
  # @return [String]
  def wrapper_classes
    "form-field"
  end

  # CSS classes for the switch container (input + label inline)
  # @return [String]
  def switch_container_classes
    "flex items-start gap-3"
  end

  # CSS classes for the switch track (background)
  # @return [String]
  def switch_track_classes
    @switch_track_classes ||= begin
      classes = [
        base_track_classes,
        size_track_classes,
        state_track_classes
      ]
      classes.compact.join(" ")
    end
  end

  # Base CSS classes for the switch track
  # @return [String]
  def base_track_classes
    "relative inline-flex shrink-0 cursor-pointer rounded-full border-2 border-transparent " \
    "transition-colors duration-200 ease-in-out focus:outline-none focus-visible:ring-2 " \
    "focus-visible:ring-offset-2"
  end

  # Size-specific CSS classes for the switch track
  # @return [String]
  def size_track_classes
    case @size
    when :small
      "h-5 w-9"
    when :medium
      "h-6 w-11"
    when :large
      "h-7 w-14"
    end
  end

  # State-specific CSS classes for the switch track
  # @return [String]
  def state_track_classes
    if @disabled
      @checked ? "bg-blue-300 cursor-not-allowed" : "bg-slate-200 cursor-not-allowed"
    elsif has_error?
      "focus-visible:ring-red-500 peer-checked:bg-red-500 bg-red-200"
    else
      "focus-visible:ring-blue-500 peer-checked:bg-blue-600 bg-slate-200"
    end
  end

  # CSS classes for the switch knob
  # @return [String]
  def switch_knob_classes
    @switch_knob_classes ||= begin
      classes = [
        base_knob_classes,
        size_knob_classes,
        checked_knob_classes,
        state_knob_classes
      ]
      classes.compact.join(" ")
    end
  end

  # Base CSS classes for the switch knob
  # @return [String]
  def base_knob_classes
    "pointer-events-none absolute left-0.5 top-1/2 -translate-y-1/2 inline-block rounded-full bg-white shadow ring-0 " \
    "transition duration-200 ease-in-out"
  end

  # Size-specific CSS classes for the switch knob
  # @return [String]
  def size_knob_classes
    case @size
    when :small
      "h-4 w-4"
    when :medium
      "h-5 w-5"
    when :large
      "h-6 w-6"
    end
  end

  # State-specific CSS classes (checked position)
  # @return [String]
  def state_knob_classes
    if @disabled
      "opacity-75"
    else
      ""
    end
  end

  # CSS classes for knob translation when checked using peer-checked
  # Translations account for the knob starting at left-0.5 (2px offset)
  # @return [String]
  def checked_knob_classes
    base = "translate-x-0"
    # Small: track w-9 (36px), knob w-4 (16px), travel = 36 - 16 - 4 (borders) = 16px, minus 2px start = 14px
    # Medium: track w-11 (44px), knob w-5 (20px), travel = 44 - 20 - 4 = 20px, minus 2px start = 18px
    # Large: track w-14 (56px), knob w-6 (24px), travel = 56 - 24 - 4 = 28px, minus 2px start = 26px
    peer_checked = case @size
    when :small
      "peer-checked:translate-x-3.5"
    when :medium
      "peer-checked:translate-x-[18px]"
    when :large
      "peer-checked:translate-x-[26px]"
    end
    "#{base} #{peer_checked}"
  end

  # CSS classes for the label element
  # @return [String]
  def label_classes
    classes = [ "font-medium text-slate-700 select-none" ]
    classes << size_label_classes
    classes << "cursor-not-allowed opacity-60" if @disabled
    classes << "cursor-pointer" unless @disabled
    classes.join(" ")
  end

  # Size-specific CSS classes for the label
  # @return [String]
  def size_label_classes
    case @size
    when :small
      "text-xs"
    when :medium
      "text-sm"
    when :large
      "text-base"
    end
  end

  # CSS classes for the switch input wrapper (for alignment)
  # Now this is a label that wraps both input and track
  # @return [String]
  def switch_input_wrapper_classes
    classes = [ "flex items-center shrink-0 relative" ]
    classes << size_input_wrapper_classes
    classes << "cursor-pointer" unless @disabled
    classes << "cursor-not-allowed" if @disabled
    classes.join(" ")
  end

  # Size-specific height for input wrapper alignment
  # @return [String]
  def size_input_wrapper_classes
    case @size
    when :small
      "h-5"
    when :medium
      "h-5"
    when :large
      "h-6"
    end
  end

  # Size-aware left margin for hints and errors to align with label
  # @return [String]
  def hint_error_margin_classes
    case @size
    when :small
      "ml-12" # 9 (track width) + 0.75rem (gap)
    when :medium
      "ml-14" # 11 (track width) + 0.75rem (gap)
    when :large
      "ml-17" # 14 (track width) + 0.75rem (gap)
    end
  end

  # Switch input attributes
  # @return [Hash]
  def switch_attributes
    attrs = {
      type: "checkbox",
      role: "switch",
      name: @name,
      id: @id,
      value: @value,
      checked: @checked || nil,
      required: @required || nil,
      disabled: @disabled || nil,
      "aria-checked": @checked ? "true" : "false",
      "aria-required": @required ? "true" : nil,
      "aria-invalid": has_error? ? "true" : nil,
      "aria-describedby": aria_describedby
    }.compact
    merge_html_attributes(attrs)
  end

  # Merged switch attributes with classes
  # @return [Hash]
  def merged_switch_attributes
    switch_attributes.merge(class: switch_input_classes)
  end

  # CSS classes for the hidden checkbox input
  # @return [String]
  def switch_input_classes
    "peer sr-only"
  end
end
