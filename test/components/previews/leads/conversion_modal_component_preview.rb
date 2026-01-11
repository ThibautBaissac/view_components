# frozen_string_literal: true

module Leads
  # @label Leads::ConversionModal
  class ConversionModalComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      account = Account.first || FactoryBot.create(:account)
      lead = FactoryBot.create(:lead, account: account, client_name: "Sophie & Thomas Martin")
      render(Leads::ConversionModalComponent.new(lead: lead))
    end

    # @label With Complete Information
    def with_complete_info
      account = Account.first || FactoryBot.create(:account)
      lead = FactoryBot.create(
        :lead,
        account: account,
        client_name: "Emma & Lucas Bernard",
        email: "emma.lucas@example.com",
        phone: "06 12 34 56 78",
        event_date_estimate: Date.new(2026, 9, 15),
        budget_min: 1_500_000, # 15,000 EUR in cents
        budget_max: 2_500_000  # 25,000 EUR in cents
      )
      render(Leads::ConversionModalComponent.new(lead: lead))
    end

    # @label Minimal Information
    def minimal_info
      account = Account.first || FactoryBot.create(:account)
      lead = FactoryBot.create(
        :lead,
        account: account,
        client_name: "Marie & Pierre",
        phone: nil,
        event_date_estimate: nil,
        budget_min: nil,
        budget_max: nil
      )
      render(Leads::ConversionModalComponent.new(lead: lead))
    end

    # @label Without Phone
    def without_phone
      account = Account.first || FactoryBot.create(:account)
      lead = FactoryBot.create(
        :lead,
        account: account,
        client_name: "Julie & Alexandre",
        phone: nil,
        event_date_estimate: Date.new(2026, 10, 20),
        budget_min: 2_000_000,
        budget_max: 3_000_000
      )
      render(Leads::ConversionModalComponent.new(lead: lead))
    end

    # @label Without Budget
    def without_budget
      account = Account.first || FactoryBot.create(:account)
      lead = FactoryBot.create(
        :lead,
        account: account,
        client_name: "Chloé & Maxime",
        event_date_estimate: Date.new(2026, 6, 5),
        budget_min: nil,
        budget_max: nil
      )
      render(Leads::ConversionModalComponent.new(lead: lead))
    end
  end
end
