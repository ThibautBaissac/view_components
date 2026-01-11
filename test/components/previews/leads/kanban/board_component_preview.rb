# frozen_string_literal: true

module Leads
  module Kanban
    # @label Leads::Kanban::Board
    class BoardComponentPreview < ViewComponent::Preview
      # @label Default with Leads
      def default
        account = Account.first || FactoryBot.create(:account)
        leads_by_status = {
          nouveau: [
            FactoryBot.create(:lead, :nouveau, account: account, client_name: "Sophie & Thomas"),
            FactoryBot.create(:lead, :nouveau, account: account, client_name: "Emma & Lucas")
          ],
          contacted: [
            FactoryBot.create(:lead, :contacted, account: account, client_name: "Julie & Alexandre")
          ],
          proposal_sent: [
            FactoryBot.create(:lead, :proposal_sent, account: account, client_name: "Marie & Pierre"),
            FactoryBot.create(:lead, :proposal_sent, account: account, client_name: "Chloé & Maxime")
          ],
          won: [
            FactoryBot.create(:lead, :won, account: account, client_name: "Laura & Antoine")
          ],
          lost: []
        }
        render(Leads::Kanban::BoardComponent.new(leads_by_status: leads_by_status))
      end

      # @label Empty Board
      def empty
        leads_by_status = {
          nouveau: [],
          contacted: [],
          proposal_sent: [],
          won: [],
          lost: []
        }
        render(Leads::Kanban::BoardComponent.new(leads_by_status: leads_by_status))
      end

      # @label Full Pipeline
      def full_pipeline
        account = Account.first || FactoryBot.create(:account)
        leads_by_status = {
          nouveau: (1..3).map { |i|
            FactoryBot.create(:lead, :nouveau, account: account, client_name: "Couple Nouveau #{i}")
          },
          contacted: (1..4).map { |i|
            FactoryBot.create(:lead, :contacted, account: account, client_name: "Couple Contacted #{i}")
          },
          proposal_sent: (1..2).map { |i|
            FactoryBot.create(:lead, :proposal_sent, account: account, client_name: "Couple Proposal #{i}")
          },
          won: (1..5).map { |i|
            FactoryBot.create(:lead, :won, account: account, client_name: "Couple Won #{i}")
          },
          lost: (1..3).map { |i|
            FactoryBot.create(:lead, :lost, account: account, client_name: "Couple Lost #{i}")
          }
        }
        render(Leads::Kanban::BoardComponent.new(leads_by_status: leads_by_status))
      end
    end
  end
end
