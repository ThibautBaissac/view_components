# frozen_string_literal: true

# @label Navigation::Pagination
# @note Displays pagination navigation for paginated collections using Pagy.
#   Supports multiple variants, sizes, and Turbo Frame integration.
class Navigation::PaginationComponentPreview < ViewComponent::Preview
  # Default pagination with page numbers
  # @label Default
  # @note The default variant shows page numbers, prev/next buttons, and handles gaps with ellipsis.
  def default
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy))
  end

  # Pagination on first page
  # @label First Page
  # @note When on the first page, the previous button is disabled.
  def first_page
    pagy = build_pagy(page: 1, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy))
  end

  # Pagination on last page
  # @label Last Page
  # @note When on the last page, the next button is disabled.
  def last_page
    pagy = build_pagy(page: 10, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy))
  end

  # Pagination with many pages showing gaps
  # @label With Gaps
  # @note When there are many pages, ellipsis (...) appear to indicate gaps in the sequence.
  def with_gaps
    pagy = build_pagy(page: 10, count: 500)
    render(Navigation::PaginationComponent.new(pagy: pagy))
  end

  # Compact variant
  # @label Compact Variant
  # @note The compact variant shows only prev/next buttons with a page indicator.
  #   Ideal for mobile or space-constrained layouts.
  def compact
    pagy = build_pagy(page: 5, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy, variant: :compact))
  end

  # Minimal variant
  # @label Minimal Variant
  # @note The minimal variant shows only Previous and Next text buttons.
  #   Best for simple navigation needs.
  def minimal
    pagy = build_pagy(page: 5, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy, variant: :minimal))
  end

  # All variants comparison
  # @label Variants Comparison
  # @note Compare all three variants side by side.
  def variants
    render_with_template(locals: {
      pagy: build_pagy(page: 5, count: 200)
    })
  end

  # Small size
  # @label Small Size
  # @note Smaller buttons for compact UIs.
  def size_small
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy, size: :small))
  end

  # Medium size (default)
  # @label Medium Size
  # @note Default button size.
  def size_medium
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy, size: :medium))
  end

  # Large size
  # @label Large Size
  # @note Larger buttons for better touch targets.
  def size_large
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy, size: :large))
  end

  # All sizes comparison
  # @label Sizes Comparison
  # @note Compare all three sizes side by side.
  def sizes
    render_with_template(locals: {
      pagy: build_pagy(page: 3, count: 100)
    })
  end

  # With page info
  # @label With Page Info
  # @note Display pagination with item count information below.
  def with_info
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(pagy: pagy, show_info: true))
  end

  # With Turbo Frame
  # @label Turbo Frame Integration
  # @note Pagination links target a specific Turbo Frame for seamless updates.
  def with_turbo_frame
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(
      pagy: pagy,
      turbo_frame: "items_list",
      turbo_action: "replace"
    ))
  end

  # Custom ARIA label
  # @label Custom ARIA Label
  # @note Use custom ARIA labels when you have multiple pagination components on a page.
  def custom_aria_label
    pagy = build_pagy(page: 3, count: 100)
    render(Navigation::PaginationComponent.new(
      pagy: pagy,
      aria_label: "Product catalog pages"
    ))
  end

  # Custom slots count
  # @label Custom Slots
  # @note Limit the number of page slots shown in the navigation.
  def custom_slots
    render_with_template(locals: {
      pagy: build_pagy(page: 10, count: 500)
    })
  end

  # Few pages (automatic hide when only one page)
  # @label Few Items
  # @note With only a few items (less than one page), pagination doesn't render.
  def few_items
    pagy = build_pagy(page: 1, count: 5)
    render(Navigation::PaginationComponent.new(pagy: pagy))
  end

  private

  def build_pagy(page: 1, count: 100, limit: 10)
    Pagy::Offset.new(count: count, page: page, limit: limit)
  end
end
