# frozen_string_literal: true

# @label Leads::Form
# @logical_path Leads
# @note
#   Form component for creating and editing leads with budget fields (in euros),
#   status selection, and validation error display. Budget fields display in euros
#   but are stored in cents (multiply by 100 on submit).
class Leads::FormComponentPreview < ViewComponent::Preview
  # @label New Lead Form
  # @note
  #   The simplest usage for creating a new lead.
  #   All fields are empty except status defaults to "nouveau".
  def new_lead
    account = Account.first || FactoryBot.create(:account)
    lead = Lead.new(account: account)

    render(Leads::FormComponent.new(
      lead: lead,
      url: "/leads",
      method: :post
    ))
  end

  # @label Edit Lead Form
  # @note
  #   Form pre-filled with existing lead data.
  #   Budget fields display in euros (converted from cents).
  def edit_lead
    account = Account.first || FactoryBot.create(:account)
    lead = Lead.first || FactoryBot.create(:lead,
      account: account,
      client_name: "Marie et Pierre",
      email: "marie@example.com",
      phone: "06 12 34 56 78",
      event_date_estimate: Date.today + 6.months,
      budget_min: 10_000_00, # 10,000€ in cents
      budget_max: 20_000_00, # 20,000€ in cents
      status: :contacted
    )

    render(Leads::FormComponent.new(
      lead: lead,
      url: "/leads/#{lead.id}",
      method: :patch,
      cancel_path: "/leads/#{lead.id}"
    ))
  end

  # @label With Validation Errors
  # @note
  #   Shows form with validation errors displayed.
  #   Error messages appear in French below invalid fields.
  def with_errors
    account = Account.first || FactoryBot.create(:account)
    lead = Lead.new(account: account, client_name: nil, email: "invalid-email")
    lead.valid? # Trigger validations

    render(Leads::FormComponent.new(
      lead: lead,
      url: "/leads",
      method: :post
    ))
  end

  # @label With Budget Range
  # @note
  #   Lead with budget range set (10,000€ - 20,000€).
  #   Note: budget values display in euros, stored in cents.
  def with_budget
    account = Account.first || FactoryBot.create(:account)
    lead = Lead.new(
      account: account,
      client_name: "Sophie et Jean",
      email: "sophie@example.com",
      budget_min: 15_000_00, # 15,000€
      budget_max: 25_000_00  # 25,000€
    )

    render(Leads::FormComponent.new(
      lead: lead,
      url: "/leads",
      method: :post
    ))
  end

  # @label Different Status Values
  # @note
  #   Shows how the status dropdown works with different values.
  def with_status
    account = Account.first || FactoryBot.create(:account)
    lead = Lead.new(
      account: account,
      client_name: "Thomas et Emma",
      email: "thomas@example.com",
      status: :proposal_sent
    )

    render(Leads::FormComponent.new(
      lead: lead,
      url: "/leads",
      method: :post
    ))
  end

  # @label Complete Example
  # @note
  #   All fields filled with realistic data.
  def complete_example
    account = Account.first || FactoryBot.create(:account)
    lead = Lead.new(
      account: account,
      client_name: "Claire et Antoine",
      email: "claire.antoine@example.com",
      phone: "+33 6 12 34 56 78",
      event_date_estimate: Date.new(2026, 8, 15),
      budget_min: 12_000_00, # 12,000€
      budget_max: 18_000_00, # 18,000€
      status: :contacted
    )

    render(Leads::FormComponent.new(
      lead: lead,
      url: "/leads",
      method: :post,
      cancel_path: "/leads"
    ))
  end
end
