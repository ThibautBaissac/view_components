# frozen_string_literal: true

class Layout::PageHeaderComponentPreview < ViewComponent::Preview
  # Simple header with just a title
  # @label Default
  def default
    render(Layout::PageHeaderComponent.new(title: "Events"))
  end

  # Header with description/subtitle
  # @label With Description
  def with_description
    render(Layout::PageHeaderComponent.new(
      title: "Events",
      description: "Manage your weddings and special events"
    ))
  end

  # Header with badge
  # @label With Badge
  def with_badge
    render(Layout::PageHeaderComponent.new(title: "John & Jane Smith")) do |header|
      header.with_badge do
        tag.span("Confirmed", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800")
      end
    end
  end

  # Header with back link
  # @label With Back Link
  def with_back_link
    render(Layout::PageHeaderComponent.new(
      title: "Event Details",
      back_url: "/events",
      back_text: "← Back to events"
    ))
  end

  # Header with action button
  # @label With Action
  def with_action
    render(Layout::PageHeaderComponent.new(title: "All Events")) do |header|
      header.with_action do
        tag.button(
          "New Event",
          class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Header with description and action
  # @label Description + Action
  def with_description_and_action
    render(Layout::PageHeaderComponent.new(
      title: "Vendors",
      description: "Manage your service providers and suppliers"
    )) do |header|
      header.with_action do
        tag.button(
          "Add Vendor",
          class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Full featured header with all options
  # @label Full Featured
  def full_featured
    render(Layout::PageHeaderComponent.new(
      title: "John & Jane Smith Wedding",
      back_url: "/events",
      back_text: "← Retour à la liste"
    )) do |header|
      header.with_badge do
        tag.span("Confirmed", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800")
      end
      header.with_action do
        tag.div(class: "flex gap-2") do
          tag.button("Edit", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700") +
          tag.button("Delete", class: "px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700")
        end
      end
    end
  end

  # Header with multiple badges
  # @label Multiple Badges
  def multiple_badges
    render(Layout::PageHeaderComponent.new(title: "Summer Wedding 2024")) do |header|
      header.with_badge do
        tag.div(class: "flex gap-2") do
          tag.span("Confirmed", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800") +
          tag.span("75 guests", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800") +
          tag.span("Premium", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800")
        end
      end
    end
  end

  # Events list page header
  # @label Events Page
  def events_page
    render(Layout::PageHeaderComponent.new(
      title: "Événements",
      description: "Gérez vos mariages et événements spéciaux"
    )) do |header|
      header.with_action do
        tag.button(
          "Nouvel événement",
          class: "px-5 py-2.5 bg-indigo-600 text-white rounded-lg text-base font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Vendors list page header
  # @label Vendors Page
  def vendors_page
    render(Layout::PageHeaderComponent.new(
      title: "Prestataires",
      description: "Gérez vos fournisseurs de services"
    )) do |header|
      header.with_action do
        tag.button(
          "Ajouter un prestataire",
          class: "px-5 py-2.5 bg-indigo-600 text-white rounded-lg text-base font-medium hover:bg-indigo-700"
        )
      end
    end
  end

  # Event detail page header
  # @label Event Detail
  def event_detail
    render(Layout::PageHeaderComponent.new(
      title: "Marie & Pierre Dupont",
      back_url: "/events",
      back_text: "← Retour à la liste"
    )) do |header|
      header.with_badge do
        tag.span("En attente", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800")
      end
      header.with_action do
        tag.div(class: "flex gap-2") do
          tag.button("Modifier", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700") +
          tag.button("Supprimer", class: "px-4 py-2 border border-red-600 text-red-600 rounded-lg text-sm font-medium hover:bg-red-50")
        end
      end
    end
  end

  # Different badge colors
  # @label Badge Variants
  def badge_variants
    render_with_template
  end
end
