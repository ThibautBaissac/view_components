# frozen_string_literal: true

# @label Form::Field::Textarea
# @logical_path Form/Field
# @note
#   A flexible textarea component that provides consistent styling,
#   labels, hints, error handling, and accessibility features.
#   Supports custom rows, resize options, and character limits.
class Form::Field::TextareaComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   The textarea will have default rows (4) and vertical resize.
  def default
    render(Form::Field::TextareaComponent.new(name: "description"))
  end

  # @label With Label
  # @note
  #   Add a label to provide context for the textarea field.
  #   The label is automatically associated with the textarea for accessibility.
  def with_label
    render(Form::Field::TextareaComponent.new(
      name: "bio",
      label: "Biography"
    ))
  end

  # @label With Placeholder
  # @note
  #   Placeholders provide hints about the expected content.
  def with_placeholder
    render(Form::Field::TextareaComponent.new(
      name: "bio",
      label: "Biography",
      placeholder: "Tell us about yourself..."
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context or instructions below the textarea.
  #   They are associated with the textarea via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::TextareaComponent.new(
      name: "bio",
      label: "Biography",
      placeholder: "Tell us about yourself...",
      hint: "Maximum 500 characters. This will be displayed on your public profile."
    ))
  end

  # @label Required Field
  # @note
  #   Required fields show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::TextareaComponent.new(
      name: "message",
      label: "Message",
      required: true,
      placeholder: "Enter your message..."
    ))
  end

  # @label With Value
  # @note
  #   Pre-populate the textarea with content.
  def with_value
    render(Form::Field::TextareaComponent.new(
      name: "notes",
      label: "Notes",
      value: "This is some pre-filled content that the user can edit or replace."
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The textarea is marked as invalid for screen readers.
  def with_error
    render(Form::Field::TextareaComponent.new(
      name: "description",
      label: "Description",
      value: "",
      error: "can't be blank"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::TextareaComponent.new(
      name: "essay",
      label: "Essay",
      value: "Too short",
      error: [ "is too short (minimum is 100 characters)", "must include an introduction" ]
    ))
  end

  # @label Custom Rows
  # @note
  #   Adjust the number of visible rows to fit the expected content length.
  def custom_rows
    render(Form::Field::TextareaComponent.new(
      name: "content",
      label: "Long Form Content",
      rows: 10,
      placeholder: "Write your article here..."
    ))
  end

  # @label Small Rows
  # @note
  #   Use fewer rows for short content fields.
  def small_rows
    render(Form::Field::TextareaComponent.new(
      name: "summary",
      label: "Short Summary",
      rows: 2,
      placeholder: "Brief summary..."
    ))
  end

  # @label Resize None
  # @note
  #   Disable resizing to maintain a fixed textarea size.
  def resize_none
    render(Form::Field::TextareaComponent.new(
      name: "fixed",
      label: "Fixed Size Textarea",
      resize: :none,
      rows: 4,
      hint: "This textarea cannot be resized."
    ))
  end

  # @label Resize Vertical (Default)
  # @note
  #   Allow only vertical resizing. This is the default behavior.
  def resize_vertical
    render(Form::Field::TextareaComponent.new(
      name: "vertical",
      label: "Vertical Resize",
      resize: :vertical,
      rows: 4,
      hint: "This textarea can only be resized vertically."
    ))
  end

  # @label Resize Horizontal
  # @note
  #   Allow only horizontal resizing.
  def resize_horizontal
    render(Form::Field::TextareaComponent.new(
      name: "horizontal",
      label: "Horizontal Resize",
      resize: :horizontal,
      rows: 4,
      hint: "This textarea can only be resized horizontally."
    ))
  end

  # @label Resize Both
  # @note
  #   Allow resizing in both directions.
  def resize_both
    render(Form::Field::TextareaComponent.new(
      name: "both",
      label: "Free Resize",
      resize: :both,
      rows: 4,
      hint: "This textarea can be resized in any direction."
    ))
  end

  # @label With Character Limit
  # @note
  #   Use maxlength to enforce a character limit.
  def with_maxlength
    render(Form::Field::TextareaComponent.new(
      name: "tweet",
      label: "Tweet",
      maxlength: 280,
      rows: 3,
      placeholder: "What's happening?",
      hint: "Maximum 280 characters."
    ))
  end

  # @label With Minimum Length
  # @note
  #   Use minlength to require a minimum amount of content.
  def with_minlength
    render(Form::Field::TextareaComponent.new(
      name: "review",
      label: "Product Review",
      minlength: 50,
      rows: 5,
      placeholder: "Share your thoughts...",
      hint: "Minimum 50 characters required."
    ))
  end

  # @label Small Size
  # @note
  #   Small size is suitable for compact layouts.
  def small_size
    render(Form::Field::TextareaComponent.new(
      name: "note",
      label: "Quick Note",
      size: :small,
      rows: 2,
      placeholder: "Add a note..."
    ))
  end

  # @label Medium Size (Default)
  # @note
  #   Medium is the default size, suitable for most use cases.
  def medium_size
    render(Form::Field::TextareaComponent.new(
      name: "description",
      label: "Description",
      size: :medium,
      placeholder: "Enter description..."
    ))
  end

  # @label Large Size
  # @note
  #   Large size is suitable for prominent input fields.
  def large_size
    render(Form::Field::TextareaComponent.new(
      name: "content",
      label: "Main Content",
      size: :large,
      rows: 6,
      placeholder: "Enter your content..."
    ))
  end

  # @label All Sizes
  # @note
  #   Comparison of all available sizes side by side.
  def all_sizes
    render_with_template
  end

  # @label Disabled
  # @note
  #   Disabled textareas cannot be focused or edited.
  def disabled
    render(Form::Field::TextareaComponent.new(
      name: "archived",
      label: "Archived Content",
      value: "This content has been archived and cannot be edited.",
      disabled: true
    ))
  end

  # @label Readonly
  # @note
  #   Readonly textareas can be focused and selected but not edited.
  def readonly
    render(Form::Field::TextareaComponent.new(
      name: "terms",
      label: "Terms of Service",
      value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      readonly: true,
      rows: 5
    ))
  end

  # @label Complete Example
  # @note
  #   A fully-featured textarea with label, hint, placeholder, and required state.
  def complete
    render(Form::Field::TextareaComponent.new(
      name: "feedback",
      label: "Your Feedback",
      placeholder: "Please share your thoughts, suggestions, or concerns...",
      hint: "Your feedback helps us improve. Be as detailed as you'd like.",
      required: true,
      rows: 6,
      maxlength: 1000
    ))
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::TextareaComponent.new(
      name: "autogrow_content",
      label: "Auto-growing Textarea",
      placeholder: "This textarea can be connected to a Stimulus controller...",
      rows: 3,
      data: {
        controller: "autogrow",
        action: "input->autogrow#resize"
      }
    ))
  end

  # @label Nested Name
  # @note
  #   Supports Rails-style nested attribute names with automatic ID generation.
  def nested_name
    render(Form::Field::TextareaComponent.new(
      name: "post[content][body]",
      label: "Post Body",
      placeholder: "Enter post content..."
    ))
  end

  # @label Code Input
  # @note
  #   Configure for code input with spellcheck disabled and monospace font.
  def code_input
    render(Form::Field::TextareaComponent.new(
      name: "code",
      label: "Code Snippet",
      placeholder: "Paste your code here...",
      rows: 8,
      resize: :both,
      spellcheck: "false",
      class: "font-mono",
      hint: "Syntax highlighting not included in this basic example."
    ))
  end
end
