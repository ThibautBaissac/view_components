# frozen_string_literal: true

# @label Form::Field::MultiSelect
# @logical_path Form/Field
# @note
#   A modern multi-select component with dropdown button and tag/chip interface.
#   Click the button to open a searchable dropdown. Selected items appear as
#   removable chips in the button. Provides better UX than native <select multiple>
#   with search filtering and click-to-remove functionality. Uses Stimulus for interactivity.
class Form::Field::MultiSelectComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   Basic usage with simple array of options.
  #   Click the dropdown button to open and search options.
  def default
    render(Form::Field::MultiSelectComponent.new(
      name: "tags[]",
      options: %w[Ruby Rails JavaScript Python Go Rust]
    ))
  end

  # @label With Label
  # @note
  #   Add a label to provide context.
  def with_label
    render(Form::Field::MultiSelectComponent.new(
      name: "skills[]",
      label: "Skills",
      options: %w[Ruby Rails JavaScript TypeScript Python Go Rust]
    ))
  end

  # @label With Selected Values
  # @note
  #   Pre-select multiple values as tags.
  def with_selected_values
    render(Form::Field::MultiSelectComponent.new(
      name: "tags[]",
      label: "Tags",
      options: %w[Ruby Rails JavaScript TypeScript Python Go],
      value: %w[Ruby Rails JavaScript]
    ))
  end

  # @label Label-Value Pairs
  # @note
  #   Use [label, value] pairs for different display and stored values.
  def label_value_pairs
    render(Form::Field::MultiSelectComponent.new(
      name: "technologies[]",
      label: "Technologies",
      options: [
        [ "Ruby Programming", "ruby" ],
        [ "Ruby on Rails", "rails" ],
        [ "JavaScript", "js" ],
        [ "TypeScript", "ts" ],
        [ "Python", "python" ],
        [ "Go", "go" ]
      ],
      value: %w[ruby rails]
    ))
  end

  # @label Grouped Options
  # @note
  #   Group options under categories for better organization.
  def grouped_options
    render(Form::Field::MultiSelectComponent.new(
      name: "technologies[]",
      label: "Select Technologies",
      options: {
        "Backend" => [
          [ "Ruby", "ruby" ],
          [ "Python", "python" ],
          [ "Go", "go" ],
          [ "Node.js", "node" ]
        ],
        "Frontend" => [
          [ "JavaScript", "js" ],
          [ "TypeScript", "ts" ],
          [ "React", "react" ],
          [ "Vue.js", "vue" ]
        ],
        "Mobile" => [
          [ "React Native", "react-native" ],
          [ "Flutter", "flutter" ],
          [ "Swift", "swift" ]
        ]
      },
      value: %w[ruby js react]
    ))
  end

  # @label With Hint
  # @note
  #   Provide additional context with hint text.
  def with_hint
    render(Form::Field::MultiSelectComponent.new(
      name: "skills[]",
      label: "Your Skills",
      options: %w[Ruby Rails JavaScript TypeScript Python Go Rust],
      hint: "Select all technologies you're proficient with. You can search and select multiple."
    ))
  end

  # @label Required Field
  # @note
  #   Mark the field as required.
  def required
    render(Form::Field::MultiSelectComponent.new(
      name: "categories[]",
      label: "Categories",
      options: %w[Technology Sports Music Art Science],
      required: true,
      hint: "At least one category is required."
    ))
  end

  # @label With Error
  # @note
  #   Error state with validation message.
  def with_error
    render(Form::Field::MultiSelectComponent.new(
      name: "tags[]",
      label: "Tags",
      options: %w[Ruby Rails JavaScript Python],
      error: "must select at least one tag"
    ))
  end

  # @label Custom Placeholder
  # @note
  #   Customize the placeholder shown when no items are selected.
  #   Click the button to open dropdown and search.
  def custom_placeholder
    render(Form::Field::MultiSelectComponent.new(
      name: "interests[]",
      label: "Your Interests",
      options: %w[Reading Writing Coding Gaming Cooking Sports Travel Music],
      placeholder: "Choose your interests..."
    ))
  end

  # @label Many Options
  # @note
  #   Demonstrates search functionality with many options.
  #   Click button to open dropdown, then use search to quickly filter.
  #   Selected items display as removable tags in the button.
  def many_options
    render(Form::Field::MultiSelectComponent.new(
      name: "programming_languages[]",
      label: "Programming Languages",
      options: %w[
        Ruby Python JavaScript TypeScript Go Rust C C++ Java Kotlin Swift
        PHP Perl Elixir Erlang Haskell Scala Clojure F# OCaml Lua R Julia
        Dart Zig Nim Crystal Elm ReasonML PureScript Idris Agda Coq
      ],
      hint: "Click to open dropdown and search languages",
      value: %w[Ruby JavaScript Go]
    ))
  end
end
