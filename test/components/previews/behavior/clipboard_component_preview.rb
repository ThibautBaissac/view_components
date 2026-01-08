# frozen_string_literal: true

# @label Behavior::Clipboard
# @logical_path Behavior
# @note Provides one-click copying of text to the clipboard with visual feedback.
#   Uses the Clipboard API with graceful fallback for older browsers. Shows temporary
#   success feedback and supports multiple button variants, sizes, and custom triggers.
#   Perfect for API keys, code snippets, shareable links, and contact information.
class Behavior::ClipboardComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Basic clipboard button with default text. Shows "Copy" text that changes to
  #   "Copied!" temporarily after clicking. Includes copy icon automatically.
  def default
    render(Behavior::ClipboardComponent.new(value: "Hello, World!"))
  end

  # @label Custom Text
  # @note Customize the button text and success feedback message to match your use case.
  #   Helpful for providing context about what's being copied.
  def with_custom_text
    render(Behavior::ClipboardComponent.new(
      value: "npm install @example/package",
      text: "Copy Command",
      success_text: "Command Copied!"
    ))
  end

  # @label Icon Only
  # @note Compact icon-only button for space-constrained layouts. Still includes proper
  #   ARIA label for accessibility. Uses ghost variant for minimal visual weight.
  def icon_only
    render(Behavior::ClipboardComponent.new(
      value: "secret-api-key-12345",
      variant: :icon,
      text: "Copy API Key"
    ))
  end

  # @label Button Variants
  # @note All available button styles: primary, secondary, outline, and ghost.
  #   Choose based on visual hierarchy and context within your interface.
  def button_variants
    render_with_template(locals: {
      variants: [ :primary, :secondary, :outline, :ghost ]
    })
  end

  # @label Button Sizes
  # @note Three sizes available: small, medium (default), and large.
  #   Size affects both button dimensions and icon scaling.
  def button_sizes
    render_with_template(locals: {
      sizes: [ :small, :medium, :large ]
    })
  end

  # @label Code Snippet
  # @note Real-world example: copy button for a code block. Common use case in
  #   documentation and technical content. Positioned absolutely in top-right corner.
  def code_snippet
    render_with_template(locals: {
      code: 'def hello_world\n  puts "Hello, World!"\nend'
    })
  end

  # @label With Custom Trigger
  # @note Use the trigger slot to provide a completely custom button or link.
  #   The component handles the copy functionality while you control the appearance.
  def with_custom_trigger
    render_with_template
  end

  # @label API Key Example
  # @note Real-world example: displaying and copying an API key with masked display.
  #   Combines readable text with easy copying for developer-focused UIs.
  def api_key
    render_with_template(locals: {
      api_key: "sk_live_abc123xyz789"
    })
  end

  # @label Multiple Values
  # @note Multiple independent clipboard buttons on the same page, each copying different values.
  #   Demonstrates that success feedback is isolated to the clicked button.
  def multiple_values
    render_with_template(locals: {
      items: [
        { label: "Email", value: "user@example.com" },
        { label: "Phone", value: "+1 (555) 123-4567" },
        { label: "Address", value: "123 Main St, City, State 12345" }
      ]
    })
  end

  # @label Long Success Duration
  # @note Customize how long the success feedback is displayed (default is 2000ms).
  #   Useful for operations where users need more time to process the feedback.
  def long_success_duration
    render(Behavior::ClipboardComponent.new(
      value: "This text was copied!",
      text: "Copy (5s feedback)",
      success_text: "Copied! (stays for 5 seconds)",
      success_duration: 5000
    ))
  end
end
