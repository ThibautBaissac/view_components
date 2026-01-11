# frozen_string_literal: true

module Leads
  module Kanban
    # @label Leads::Kanban::Column
    class ColumnComponentPreview < ViewComponent::Preview
      # @label Nouveau Column
      def nouveau
        account = Account.first || FactoryBot.create(:account)
        leads = [
          FactoryBot.create(:lead, :nouveau, account: account, client_name: "Sophie & Thomas"),
          FactoryBot.create(:lead, :nouveau, account: account, client_name: "Emma & Lucas")
        ]
        render(Leads::Kanban::ColumnComponent.new(status: :nouveau, leads: leads))
      end

      # @label Contacted Column
      def contacted
        account = Account.first || FactoryBot.create(:account)
        leads = [
          FactoryBot.create(:lead, :contacted, account: account, client_name: "Julie & Alexandre")
        ]
        render(Leads::Kanban::ColumnComponent.new(status: :contacted, leads: leads))
      end

      # @label Proposal Sent Column
      def proposal_sent
        account = Account.first || FactoryBot.create(:account)
        leads = [
          FactoryBot.create(:lead, :proposal_sent, account: account, client_name: "Marie & Pierre"),
          FactoryBot.create(:lead, :proposal_sent, account: account, client_name: "Chloé & Maxime"),
          FactoryBot.create(:lead, :proposal_sent, account: account, client_name: "Laura & Antoine")
        ]
        render(Leads::Kanban::ColumnComponent.new(status: :proposal_sent, leads: leads))
      end

      # @label Won Column
      def won
        account = Account.first || FactoryBot.create(:account)
        leads = [
          FactoryBot.create(:lead, :won, account: account, client_name: "Sarah & Julien")
        ]
        render(Leads::Kanban::ColumnComponent.new(status: :won, leads: leads))
      end

      # @label Lost Column
      def lost
        account = Account.first || FactoryBot.create(:account)
        leads = [
          FactoryBot.create(:lead, :lost, account: account, client_name: "Claire & Nicolas")
        ]
        render(Leads::Kanban::ColumnComponent.new(status: :lost, leads: leads))
      end

      # @label Empty Column
      def empty
        render(Leads::Kanban::ColumnComponent.new(status: :nouveau, leads: []))
      end
    end
  end
end
