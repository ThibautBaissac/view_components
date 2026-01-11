# frozen_string_literal: true

# @label Feedback::Toast
# @note Displays temporary toast notifications that appear briefly to provide feedback
#   on user actions. Toasts auto-dismiss after a timeout and can be manually dismissed.
class Feedback::ToastComponentPreview < ViewComponent::Preview
  # @label Default (Info)
  # @note Default toast with info styling. Auto-dismisses after 5 seconds.
  def default
    render(Feedback::ToastComponent.new(
      message: "This is an informational toast notification."
    ))
  end

  # @label Success
  # @note Success toast for confirming successful operations.
  #   Auto-dismisses after 5 seconds.
  def success
    render(Feedback::ToastComponent.new(
      message: "Your changes have been saved successfully!",
      type: :success
    ))
  end

  # @label Warning
  # @note Warning toast to caution users about potential issues.
  #   Auto-dismisses after 5 seconds.
  def warning
    render(Feedback::ToastComponent.new(
      message: "Your session will expire in 5 minutes.",
      type: :warning
    ))
  end

  # @label Error
  # @note Error toast for critical issues. Does NOT auto-dismiss by default
  #   to ensure users see the error message.
  def error
    render(Feedback::ToastComponent.new(
      message: "Unable to save changes. Please try again.",
      type: :error
    ))
  end

  # @label With Title
  # @note Toast with a prominent title above the message.
  def with_title
    render(Feedback::ToastComponent.new(
      message: "Your document has been saved to the cloud.",
      type: :success
    )) do |toast|
      toast.with_title { "Document Saved" }
    end
  end

  # @label With Action
  # @note Toast with an action link for user interaction.
  #   Useful for undo operations or navigation.
  def with_action
    render(Feedback::ToastComponent.new(
      message: "Item moved to trash.",
      type: :info
    )) do |toast|
      toast.with_action(text: "Undo", url: "#undo")
    end
  end

  # @label With Custom Icon
  # @note Override the default type icon with a custom one.
  def with_custom_icon
    render(Feedback::ToastComponent.new(
      message: "You have a new message!",
      type: :info
    )) do |toast|
      toast.with_icon(name: "envelope", variant: :solid, color: :primary)
    end
  end

  # @label Without Icon
  # @note Toast without an icon for a minimal appearance.
  def without_icon
    render(Feedback::ToastComponent.new(
      message: "This toast has no icon.",
      type: :info,
      show_icon: false
    ))
  end

  # @label Non-Dismissible
  # @note Toast without a dismiss button. Useful for important
  #   notifications that should not be dismissed manually.
  def non_dismissible
    render(Feedback::ToastComponent.new(
      message: "Processing your request...",
      type: :info,
      dismissible: false,
      timeout: nil
    ))
  end

  # @label Custom Timeout
  # @note Toast with a custom timeout of 10 seconds.
  def custom_timeout
    render(Feedback::ToastComponent.new(
      message: "This toast will disappear in 10 seconds.",
      type: :info,
      timeout: 10000
    ))
  end

  # @label Without Progress Bar
  # @note Toast without the progress bar indicator.
  def without_progress
    render(Feedback::ToastComponent.new(
      message: "No progress bar on this toast.",
      type: :success,
      show_progress: false
    ))
  end

  # @label Complete Example
  # @note Full-featured toast with title, action, and custom styling.
  def complete
    render(Feedback::ToastComponent.new(
      message: "Your file has been uploaded and is ready to share.",
      type: :success,
      id: "upload-complete-toast"
    )) do |toast|
      toast.with_title { "Upload Complete" }
      toast.with_action(text: "View File", url: "#view")
    end
  end

  # @label Error with Action
  # @note Error toast with a retry action. Does not auto-dismiss.
  def error_with_action
    render(Feedback::ToastComponent.new(
      message: "Failed to connect to server.",
      type: :error
    )) do |toast|
      toast.with_title { "Connection Error" }
      toast.with_action(text: "Retry", url: "#retry")
    end
  end

  # @label All Types
  # @note Preview showing all toast types stacked vertically.
  def all_types
    render_with_template(locals: {
      toasts: [
        { message: "Info toast notification", type: :info },
        { message: "Success toast notification", type: :success },
        { message: "Warning toast notification", type: :warning },
        { message: "Error toast notification", type: :error }
      ]
    })
  end

  # @label Toast Stack
  # @note Example showing how multiple toasts can be stacked.
  #   Typically toasts are rendered in a fixed container.
  def toast_stack
    render_with_template
  end
end
