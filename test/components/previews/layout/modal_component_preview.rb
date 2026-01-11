# frozen_string_literal: true

# @label Layout::Modal
# @note A flexible modal dialog component that displays content in an overlay.
#   Uses the native HTML <dialog> element for accessibility and supports
#   different sizes, dismissible behavior, and Turbo integration.
class Layout::ModalComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Basic modal with default settings. Click the trigger button to open.
  def default
    render_with_template(locals: {
      modal_id: "default-modal"
    })
  end

  # @label With Title
  # @note Modal with a title displayed in the header.
  def with_title
    render_with_template(locals: {
      modal_id: "titled-modal",
      title: "Modal Title"
    })
  end

  # @label Small Size
  # @note Compact modal for simple dialogs or confirmations.
  def small
    render_with_template(locals: {
      modal_id: "small-modal",
      size: :small,
      title: "Small Modal"
    })
  end

  # @label Large Size
  # @note Larger modal for complex content or forms.
  def large
    render_with_template(locals: {
      modal_id: "large-modal",
      size: :large,
      title: "Large Modal"
    })
  end

  # @label Full Size
  # @note Extra-large modal for extensive content.
  def full
    render_with_template(locals: {
      modal_id: "full-modal",
      size: :full,
      title: "Full Size Modal"
    })
  end

  # @label With All Slots
  # @note Modal using header, body, and footer slots for complete customization.
  def with_all_slots
    render_with_template(locals: {
      modal_id: "slots-modal"
    })
  end

  # @label Non-Dismissible
  # @note Modal that cannot be dismissed by ESC key, backdrop click, or close button.
  #   User must complete the required action.
  def non_dismissible
    render_with_template(locals: {
      modal_id: "required-modal",
      dismissible: false,
      title: "Required Action"
    })
  end

  # @label With Form
  # @note Modal containing a form. Closes automatically on successful submission
  #   when close_on_submit is true (default).
  def with_form
    render_with_template(locals: {
      modal_id: "form-modal",
      title: "Edit Profile"
    })
  end

  # @label Open by Default
  # @note Modal that opens automatically when rendered. Useful for Turbo Frame responses.
  def open_by_default
    render(Layout::ModalComponent.new(
      id: "auto-open-modal",
      title: "Automatically Opened",
      open: true
    )) do |modal|
      modal.with_body do
        "<p class='text-gray-600'>This modal opened automatically when the page loaded.</p>".html_safe
      end
      modal.with_footer do
        "<button class='px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700' data-action='click->components--modal#close'>Got it</button>".html_safe
      end
    end
  end
end
