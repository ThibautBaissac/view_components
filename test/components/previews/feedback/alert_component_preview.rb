# frozen_string_literal: true

# @label Feedback::Alert
# @note Displays contextual feedback messages with different types and customization options.
#   Use alerts to communicate important information, status updates, or errors to users.
class Feedback::AlertComponentPreview < ViewComponent::Preview
  # @label Default (Info)
  # @note Use info alerts for general information that doesn't require immediate action.
  #   This is the default type when no type is specified.
  def default
    render(Feedback::AlertComponent.new(
      message: "This is an informational alert with helpful context for the user."
    ))
  end

  # @label Success
  # @note Use success alerts to confirm successful operations like form submissions,
  #   saves, or completed actions.
  def success
    render(Feedback::AlertComponent.new(
      message: "Your changes have been saved successfully!",
      type: :success
    ))
  end

  # @label Warning
  # @note Use warning alerts to caution users about potential issues or actions
  #   that may have consequences. Requires user attention but not immediate action.
  def warning
    render(Feedback::AlertComponent.new(
      message: "Your session will expire in 5 minutes. Please save your work.",
      type: :warning
    ))
  end

  # @label Error
  # @note Use error alerts for critical issues that prevent the user from proceeding.
  #   Always provide actionable guidance when possible.
  def error
    render(Feedback::AlertComponent.new(
      message: "Unable to process your request. Please try again later.",
      type: :error
    ))
  end

  # @label Dismissible
  # @note Add dismissible: true to allow users to close the alert. Uses Stimulus
  #   controller for smooth fade-out animation.
  def dismissible
    render(Feedback::AlertComponent.new(
      message: "You can dismiss this alert by clicking the X button.",
      type: :info,
      dismissible: true
    ))
  end

  # @label Without Icon
  # @note Set show_icon: false to hide the default type icon. Useful for compact layouts
  #   or when the context is already clear.
  def without_icon
    render(Feedback::AlertComponent.new(
      message: "This alert doesn't show an icon.",
      type: :success,
      show_icon: false
    ))
  end

  # @label With Title
  # @note Use the title slot to add a prominent heading above the message.
  #   Good for important alerts that need extra emphasis.
  def with_title
    render(Feedback::AlertComponent.new(
      message: "Make sure to verify your email address to receive notifications.",
      type: :warning
    )) do |alert|
      alert.with_title { "Email Verification Required" }
    end
  end

  # @label With Custom Icon
  # @note Override the default type icon with a custom one using the icon slot.
  #   Accepts all Foundation::IconComponent parameters.
  def with_custom_icon
    render(Feedback::AlertComponent.new(
      message: "This alert uses a custom icon instead of the default type icon.",
      type: :info
    )) do |alert|
      alert.with_icon(name: "check-circle", variant: :solid, color: :success)
    end
  end

  # @label With Actions
  # @note Add action links using the actions slot. Useful for providing next steps
  #   or allowing users to take immediate action.
  def with_actions
    render(Feedback::AlertComponent.new(
      message: "A new version of this app is available. Update now to get the latest features.",
      type: :info
    )) do |alert|
      alert.with_action(text: "Update Now", url: "#update")
      alert.with_action(text: "Later", url: "#dismiss")
    end
  end

  # @label Complete Example
  # @note Demonstrates all features combined: title, message, actions, and dismissible.
  #   Use this pattern for important notifications requiring user action.
  def complete
    render(Feedback::AlertComponent.new(
      message: "Your profile is missing some important information. Please complete your profile to unlock all features.",
      type: :warning,
      dismissible: true,
      id: "profile-incomplete-alert"
    )) do |alert|
      alert.with_title { "Profile Incomplete" }
      alert.with_action(text: "Complete Profile", url: "#profile")
      alert.with_action(text: "Remind Me Later", url: "#later")
    end
  end

  # @label Multiple Alerts
  # @note Example showing multiple alerts stacked. Add spacing between alerts
  #   using Tailwind's space-y utility classes.
  def multiple_alerts
    render_with_template(locals: {
      alerts: [
        { message: "Info alert", type: :info },
        { message: "Success alert", type: :success },
        { message: "Warning alert", type: :warning },
        { message: "Error alert", type: :error }
      ]
    })
  end

  # Success alert with title and actions
  # @label Success with Details
  def success_with_details
    render(Feedback::AlertComponent.new(
      message: "Your order has been confirmed and is being processed. You'll receive an email confirmation shortly.",
      type: :success,
      dismissible: true
    )) do |alert|
      alert.with_title { "Order Confirmed!" }
      alert.with_action(text: "View Order", url: "#order")
      alert.with_action(text: "Track Shipment", url: "#track")
    end
  end

  # Error alert with title and retry action
  # @label Error with Action
  def error_with_action
    render(Feedback::AlertComponent.new(
      message: "The server encountered an error while processing your request. Please try again.",
      type: :error,
      dismissible: true
    )) do |alert|
      alert.with_title { "Something Went Wrong" }
      alert.with_action(text: "Retry", url: "#retry")
      alert.with_action(text: "Contact Support", url: "#support")
    end
  end

  # Dynamic parameters for testing different configurations
  # @label Playground
  # @param message text
  # @param type select { choices: [info, success, warning, error] }
  # @param dismissible toggle
  # @param show_icon toggle
  def playground(message: "This is a customizable alert message", type: :info, dismissible: false, show_icon: true)
    render(Feedback::AlertComponent.new(
      message: message,
      type: type.to_sym,
      dismissible: dismissible,
      show_icon: show_icon
    ))
  end
end
