# frozen_string_literal: true

class Layout::EmptyStateComponentPreview < ViewComponent::Preview
  # Basic empty state with title and description
  # @label Default
  def default
    render(Layout::EmptyStateComponent.new(
      title: "No events yet",
      description: "Get started by creating your first event"
    ))
  end

  # Empty state with icon
  # @label With Icon
  def with_icon
    render(Layout::EmptyStateComponent.new(
      icon_name: "calendar",
      title: "No events scheduled",
      description: "Start planning your first wedding event"
    ))
  end

  # Empty state with icon and action button
  # @label With Action
  def with_action
    render(Layout::EmptyStateComponent.new(
      icon_name: "users",
      title: "No vendors yet",
      description: "Add your first vendor to get started with event planning"
    )) do |empty_state|
      empty_state.with_action do
        tag.button(
          "Add Your First Vendor",
          class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Compact variant with less padding
  # @label Compact
  def compact
    render(Layout::EmptyStateComponent.new(
      icon_name: "document-text",
      title: "No notes available",
      compact: true
    ))
  end

  # Empty state for events list
  # @label Empty Events
  def empty_events
    render(Layout::EmptyStateComponent.new(
      icon_name: "calendar-days",
      icon_size: :xl,
      title: "Aucun événement",
      description: "Commencez par créer votre premier mariage"
    )) do |empty_state|
      empty_state.with_action do
        tag.button(
          "Créer un événement",
          class: "px-5 py-2.5 bg-indigo-600 text-white rounded-lg text-base font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Empty state for vendors list
  # @label Empty Vendors
  def empty_vendors
    render(Layout::EmptyStateComponent.new(
      icon_name: "building-storefront",
      icon_size: :xl,
      title: "Aucun prestataire",
      description: "Ajoutez des prestataires pour organiser vos événements"
    )) do |empty_state|
      empty_state.with_action do
        tag.button(
          "Ajouter un prestataire",
          class: "px-5 py-2.5 bg-indigo-600 text-white rounded-lg text-base font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Empty state for search results
  # @label No Search Results
  def no_search_results
    render(Layout::EmptyStateComponent.new(
      icon_name: "magnifying-glass",
      title: "No results found",
      description: "Try adjusting your search or filter criteria"
    ))
  end

  # Empty state with different icon variants
  # @label Icon Variants
  def icon_variants
    render_with_template
  end

  # Empty state with different icon sizes
  # @label Icon Sizes
  def icon_sizes
    render_with_template
  end

  # Compact vs normal comparison
  # @label Compact Comparison
  def compact_comparison
    render_with_template
  end
end
