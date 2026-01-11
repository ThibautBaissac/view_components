# frozen_string_literal: true

# Preview for Public::LeadFormComponent
class Public::LeadFormComponentPreview < ViewComponent::Preview
  # Default lead form with all fields enabled
  # @!group Default
  def default
    config = PublicPageConfig.new(
      slug: "mon-mariage",
      title: "Organisez votre mariage de rêve",
      description: "Contactez-nous pour discuter de votre projet",
      primary_color: "#8B5CF6",
      show_phone: true,
      show_event_date: true,
      show_budget: true,
      show_message: true
    )
    lead = Lead.new

    render Public::LeadFormComponent.new(
      config: config,
      lead: lead,
      url: "#"
    )
  end
  # @!endgroup

  # Lead form with custom branding (blue)
  # @!group Variations
  def custom_branding
    config = PublicPageConfig.new(
      slug: "wedding-planner",
      title: "Plan Your Dream Wedding",
      primary_color: "#3B82F6",
      show_phone: true,
      show_event_date: true,
      show_budget: true,
      show_message: true
    )
    lead = Lead.new

    render Public::LeadFormComponent.new(
      config: config,
      lead: lead,
      url: "#"
    )
  end

  # Minimal form with only required fields
  def minimal
    config = PublicPageConfig.new(
      slug: "contact",
      title: "Contact Us",
      primary_color: "#10B981",
      show_phone: false,
      show_event_date: false,
      show_budget: false,
      show_message: false
    )
    lead = Lead.new

    render Public::LeadFormComponent.new(
      config: config,
      lead: lead,
      url: "#"
    )
  end

  # Form with some optional fields
  def partial_fields
    config = PublicPageConfig.new(
      slug: "event-planning",
      title: "Event Planning Services",
      primary_color: "#F59E0B",
      show_phone: true,
      show_event_date: true,
      show_budget: false,
      show_message: true
    )
    lead = Lead.new

    render Public::LeadFormComponent.new(
      config: config,
      lead: lead,
      url: "#"
    )
  end
  # @!endgroup
end
