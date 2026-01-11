# frozen_string_literal: true

class Layout::CardComponentPreview < ViewComponent::Preview
  # Basic card with default padding
  # @label Default
  def default
    render(Layout::CardComponent.new) do
      tag.p("This is a simple card with default large padding. Perfect for displaying content in a styled container.")
    end
  end

  # Card with header title
  # @label With Header
  def with_header
    render(Layout::CardComponent.new) do |card|
      card.with_header(title: "Event Details")
      tag.div do
        tag.p("Event information and details go here.", class: "text-slate-600")
      end
    end
  end

  # Card with header and actions
  # @label With Header Actions
  def with_header_actions
    render(Layout::CardComponent.new) do |card|
      card.with_header(title: "Vendors") do
        tag.button("Add Vendor", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
      tag.p("List of vendors will appear here.", class: "text-slate-600")
    end
  end

  # Card with footer
  # @label With Footer
  def with_footer
    render(Layout::CardComponent.new) do |card|
      card.with_header(title: "Order Summary")
      tag.div(class: "space-y-2") do
        tag.div(class: "flex justify-between") do
          tag.span("Subtotal:") + tag.span("€1,000", class: "font-medium")
        end +
        tag.div(class: "flex justify-between") do
          tag.span("Commission:") + tag.span("€234", class: "font-medium")
        end
      end +
      card.with_footer do
        tag.div(class: "flex justify-between font-bold text-lg") do
          tag.span("Total:") + tag.span("€1,234")
        end
      end
    end
  end

  # Sticky sidebar card
  # @label Sticky Card
  def sticky_card
    render(Layout::CardComponent.new(sticky: true)) do |card|
      card.with_header(title: "Actions")
      tag.div(class: "space-y-3") do
        tag.button("Edit Event", class: "w-full px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700") +
        tag.button("Delete Event", class: "w-full px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700") +
        tag.p("This card will stick to the top when scrolling.", class: "text-xs text-slate-500 mt-4")
      end
    end
  end

  # Card with no padding
  # @label No Padding
  def no_padding
    render(Layout::CardComponent.new(padding: :none)) do
      tag.img(src: "https://via.placeholder.com/400x200", alt: "Placeholder", class: "w-full rounded-t-2xl") +
      tag.div(class: "p-6") do
        tag.h3("Image Card", class: "text-lg font-semibold mb-2") +
        tag.p("Using padding: :none allows you to add images that extend to the edges.", class: "text-slate-600")
      end
    end
  end

  # Card with small padding
  # @label Small Padding
  def small_padding
    render(Layout::CardComponent.new(padding: :small)) do
      tag.p("This card uses small padding (p-4).", class: "text-slate-600")
    end
  end

  # Card with medium padding
  # @label Medium Padding
  def medium_padding
    render(Layout::CardComponent.new(padding: :medium)) do
      tag.p("This card uses medium padding (p-6).", class: "text-slate-600")
    end
  end

  # Complete card example with all features
  # @label Full Featured
  def full_featured
    render(Layout::CardComponent.new(padding: :large)) do |card|
      card.with_header(title: "John & Jane Smith Wedding") do
        tag.div(class: "flex gap-2") do
          tag.button("Edit", class: "px-3 py-1.5 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700") +
          tag.button("Delete", class: "px-3 py-1.5 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700")
        end
      end
      tag.div(class: "space-y-4") do
        tag.div do
          tag.span("Date:", class: "font-medium") + tag.span(" June 15, 2024", class: "text-slate-600 ml-2")
        end +
        tag.div do
          tag.span("Status:", class: "font-medium") + tag.span(" Confirmed", class: "inline-block ml-2 px-2 py-1 bg-green-100 text-green-800 rounded text-sm")
        end +
        tag.div do
          tag.span("Guests:", class: "font-medium") + tag.span(" 75", class: "text-slate-600 ml-2")
        end
      end +
      card.with_footer do
        tag.div(class: "flex justify-between items-center") do
          tag.span("Total Budget:", class: "text-slate-600") +
          tag.span("€15,000", class: "text-xl font-bold text-indigo-600")
        end
      end
    end
  end

  # Multiple cards in a grid
  # @label Grid Layout
  def grid_layout
    render_with_template
  end
end
