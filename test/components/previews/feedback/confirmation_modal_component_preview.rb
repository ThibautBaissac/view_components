# frozen_string_literal: true

# @label Feedback::ConfirmationModal
# @note A specialized confirmation modal for destructive or important actions.
#   Provides a consistent UX for confirmations with appropriate styling,
#   icons, and action buttons. Uses Layout::ModalComponent as the base.
class Feedback::ConfirmationModalComponentPreview < ViewComponent::Preview
  # @label Danger (Default)
  # @note Default danger confirmation for destructive actions like delete.
  #   Uses red styling to indicate potential data loss.
  def default
    render_with_template(locals: {
      modal_id: "delete-confirm"
    })
  end

  # @label Warning
  # @note Warning confirmation for actions that have consequences but are reversible.
  #   Uses yellow styling to caution the user.
  def warning
    render_with_template(locals: {
      modal_id: "publish-confirm"
    })
  end

  # @label Info
  # @note Info confirmation for neutral or positive actions that need confirmation.
  #   Uses blue styling for a calmer appearance.
  def info
    render_with_template(locals: {
      modal_id: "submit-confirm"
    })
  end

  # @label With URL Action
  # @note Confirmation with a URL that will be triggered on confirm.
  #   The confirm button becomes a link with the specified HTTP method.
  def with_url
    render_with_template(locals: {
      modal_id: "url-confirm"
    })
  end

  # @label With Description
  # @note Confirmation with additional description slot for extra context.
  def with_description
    render_with_template(locals: {
      modal_id: "description-confirm"
    })
  end

  # @label Without Icon
  # @note Minimal confirmation without the icon for a cleaner look.
  def without_icon
    render_with_template(locals: {
      modal_id: "no-icon-confirm"
    })
  end

  # @label With Custom Icon
  # @note Confirmation with a custom icon using the icon slot.
  def with_custom_icon
    render_with_template(locals: {
      modal_id: "custom-icon-confirm"
    })
  end

  # @label Delete Item Example
  # @note Real-world example: confirming deletion of an item.
  def delete_example
    render_with_template(locals: {
      modal_id: "delete-item-confirm"
    })
  end

  # @label Logout Example
  # @note Real-world example: confirming logout action.
  def logout_example
    render_with_template(locals: {
      modal_id: "logout-confirm"
    })
  end
end
