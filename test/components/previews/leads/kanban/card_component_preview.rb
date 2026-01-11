# frozen_string_literal: true

module Leads
  module Kanban
    # @label Leads::Kanban::Card
    class CardComponentPreview < ViewComponent::Preview
      # @label Default Card
      def default
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(:lead, account: account, client_name: "Sophie & Thomas Martin")
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Card with All Fields
      def with_all_fields
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(
          :lead,
          account: account,
          client_name: "Emma & Lucas Bernard",
          email: "emma.lucas@example.com",
          phone: "06 12 34 56 78",
          event_date_estimate: Date.new(2026, 9, 15),
          budget_min: 1_500_000,
          budget_max: 2_500_000
        )
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Card without Phone
      def without_phone
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(
          :lead,
          account: account,
          client_name: "Julie & Alexandre",
          phone: nil,
          event_date_estimate: Date.new(2026, 10, 20)
        )
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Card without Event Date
      def without_event_date
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(
          :lead,
          account: account,
          client_name: "Marie & Pierre",
          event_date_estimate: nil
        )
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Card without Budget
      def without_budget
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(
          :lead,
          account: account,
          client_name: "Chloé & Maxime",
          budget_min: nil,
          budget_max: nil
        )
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Minimal Card
      def minimal
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(
          :lead,
          :minimal,
          account: account,
          client_name: "Laura & Antoine"
        )
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Nouveau Status
      def nouveau_status
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(:lead, :nouveau, account: account)
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Contacted Status
      def contacted_status
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(:lead, :contacted, account: account)
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Proposal Sent Status
      def proposal_sent_status
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(:lead, :proposal_sent, account: account)
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Won Status
      def won_status
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(:lead, :won, account: account)
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end

      # @label Lost Status
      def lost_status
        account = Account.first || FactoryBot.create(:account)
        lead = FactoryBot.create(:lead, :lost, account: account)
        render(Leads::Kanban::CardComponent.new(lead: lead))
      end
    end
  end
end
