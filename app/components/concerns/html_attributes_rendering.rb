# frozen_string_literal: true

# HtmlAttributesRendering
#
# Provides reusable methods for rendering HTML attributes in ViewComponents.
# Supports both tag.attributes (Rails-preferred) and html_attributes_string (legacy).
# This concern handles various attribute types including nested hashes (data, aria),
# boolean attributes, and properly escapes values to prevent XSS.
#
# SECURITY NOTE:
# Both methods ensure XSS protection via ERB::Util.html_escape. All user-provided
# values are escaped before being marked html_safe. Any modifications to these
# methods must maintain this escaping behavior.
#
# @example Preferred usage with tag.attributes (Rails way)
#   class MyComponent < ViewComponent::Base
#     include HtmlAttributesRendering
#
#     def initialize(**html_attributes)
#       @html_attributes = html_attributes
#     end
#
#     # In your template:
#     # <div <%= tag.attributes(merged_html_attributes) %>>
#
#     private
#
#     def merged_html_attributes
#       { id: "my-id", class: "my-class" }.merge(@html_attributes)
#     end
#   end
#
# @example Legacy usage with html_attributes_string
#   class MyComponent < ViewComponent::Base
#     include HtmlAttributesRendering
#
#     def initialize(**html_attributes)
#       @html_attributes = html_attributes
#     end
#
#     # In your template:
#     # <div <%= html_attributes_string %>>
#   end
#
module HtmlAttributesRendering
  extend ActiveSupport::Concern

  private

  # Converts HTML attributes hash to a safe HTML attribute string.
  # Automatically excludes :class attribute (should be handled separately).
  #
  # SECURITY: All values are escaped via ERB::Util.html_escape before marking html_safe.
  # Any modifications to this method must maintain this escaping behavior to prevent XSS.
  #
  # NOTE: Prefer using tag.attributes() in new components for better Rails integration.
  # This method is maintained for backward compatibility.
  #
  # Handles:
  # - Nested hashes (data: {controller: "x"}, aria: {label: "y"}) -> data-controller="x" aria-label="y"
  # - Boolean true -> attribute name only (e.g., disabled)
  # - Boolean false/nil -> omitted
  # - Regular values -> key="escaped_value"
  #
  # @param attrs [Hash, nil] Hash of HTML attributes. If nil, uses attributes_for_rendering
  # @return [ActiveSupport::SafeBuffer] Safe HTML string ready for template rendering
  #
  # @example Basic usage
  #   html_attributes_string
  #   # => 'id="my-id" role="button"'
  #
  # @example With nested data attributes
  #   html_attributes_string(data: {controller: "dropdown", action: "click->dropdown#toggle"})
  #   # => 'data-controller="dropdown" data-action="click->dropdown#toggle"'
  #
  # @example Override attributes
  #   html_attributes_string(custom_attributes)
  #
  # @deprecated Use tag.attributes(merged_html_attributes) in templates instead
  def html_attributes_string(attrs = nil)
    attrs ||= attributes_for_rendering
    attrs = attrs.except(:class)

    attrs.map { |key, value|
      if value.is_a?(Hash)
        # Handle nested hashes like data: { controller: "x" } or aria: { label: "y" }
        value.map { |k, v|
          "#{key.to_s.tr('_', '-')}-#{k.to_s.tr('_', '-')}=\"#{ERB::Util.html_escape(v)}\""
        }.join(" ")
      elsif value == true
        # Boolean true -> attribute name only
        key.to_s.tr("_", "-")
      elsif value == false || value.nil?
        # Boolean false or nil -> omit attribute
        nil
      else
        # Regular value -> key="value"
        "#{key.to_s.tr('_', '-')}=\"#{ERB::Util.html_escape(value)}\""
      end
    }.compact.join(" ").html_safe
  end

  # Override this method in components to provide the attributes hash.
  # Default implementation looks for @html_attributes instance variable.
  #
  # @return [Hash] HTML attributes hash
  def attributes_for_rendering
    return @html_attributes if defined?(@html_attributes)

    {}
  end

  # Deeply merges HTML attributes, handling nested hashes like data and aria attributes.
  # Use this for merging default component attributes with user-provided attributes.
  #
  # @param defaults [Hash] Default attributes from the component
  # @param overrides [Hash] User-provided attributes (typically @html_attributes)
  # @return [Hash] Merged attributes hash
  #
  # @example Merging data attributes
  #   deep_merge_attributes(
  #     { data: { controller: "modal" }, class: "base" },
  #     { data: { action: "click->modal#close" }, class: "custom" }
  #   )
  #   # => { data: { controller: "modal", action: "click->modal#close" }, class: "custom base" }
  def deep_merge_attributes(defaults, overrides)
    result = defaults.deep_dup

    overrides.each do |key, value|
      if key == :class || key == "class"
        # Special handling for class: concatenate instead of replacing
        result[key] = [ result[key], value ].compact.join(" ").presence
      elsif value.is_a?(Hash) && result[key].is_a?(Hash)
        # Deep merge nested hashes (data, aria, etc.)
        result[key] = result[key].merge(value)
      else
        # Regular merge: override takes precedence
        result[key] = value
      end
    end

    result
  end
end
