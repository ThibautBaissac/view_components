# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ImpersonationBannerComponent, type: :component do
  let(:account) { create(:account) }
  let(:super_admin) { create(:user, :super_admin, account: account) }
  let(:impersonated_user) { create(:user, account: account) }

  describe "#render?" do
    context "when true_user is present and different from impersonated_user (impersonating)" do
      it "returns true when true_user is a super_admin" do
        component = described_class.new(true_user: super_admin, impersonated_user: impersonated_user)
        expect(component.render?).to be true
      end
    end

    context "when true_user is nil (not impersonating)" do
      it "returns false" do
        component = described_class.new(true_user: nil, impersonated_user: impersonated_user)
        expect(component.render?).to be false
      end
    end

    context "when true_user equals impersonated_user (not actually impersonating)" do
      it "returns false" do
        component = described_class.new(true_user: super_admin, impersonated_user: super_admin)
        expect(component.render?).to be false
      end
    end

    context "when true_user is not a super_admin" do
      let(:regular_user) { create(:user, account: account) }

      it "returns false for defense in depth" do
        component = described_class.new(true_user: regular_user, impersonated_user: impersonated_user)
        expect(component.render?).to be false
      end
    end
  end

  describe "rendering" do
    context "when impersonating" do
      it "renders the banner with impersonated user email" do
        render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

        expect(page).to have_text("Vous êtes connecté en tant que")
        expect(page).to have_text(impersonated_user.email)
      end

      it "renders a button to stop impersonation" do
        render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

        expect(page).to have_button("Revenir à mon compte")
      end

      it "has a warning color scheme" do
        render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

        expect(page).to have_css("div.bg-yellow-500")
      end

      it "has proper ARIA attributes for accessibility" do
        render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

        expect(page).to have_css('[role="alert"]')
        expect(page).to have_css('[aria-live="polite"]')
      end
    end

    context "when not impersonating" do
      it "does not render anything" do
        render_inline(described_class.new(true_user: nil, impersonated_user: impersonated_user))

        expect(page).not_to have_text("Vous êtes connecté en tant que")
      end
    end
  end

  describe "HTML attributes" do
    context "with custom classes" do
      it "merges custom classes with default classes" do
        component = described_class.new(
          true_user: super_admin,
          impersonated_user: impersonated_user,
          class: "custom-class shadow-lg"
        )
        render_inline(component)

        expect(page).to have_css(".bg-yellow-500.custom-class.shadow-lg")
      end
    end

    context "with data attributes" do
      it "adds data attributes to the banner" do
        component = described_class.new(
          true_user: super_admin,
          impersonated_user: impersonated_user,
          data: { testid: "impersonation-banner", controller: "test" }
        )
        render_inline(component)

        expect(page).to have_css("[data-testid='impersonation-banner']")
        expect(page).to have_css("[data-controller='test']")
      end
    end

    context "with custom ID" do
      it "adds custom ID to the banner" do
        component = described_class.new(
          true_user: super_admin,
          impersonated_user: impersonated_user,
          id: "custom-banner"
        )
        render_inline(component)

        expect(page).to have_css("#custom-banner")
      end
    end
  end

  describe "internationalization" do
    it "uses translated message text" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_text("Vous êtes connecté en tant que")
    end

    it "uses translated button text" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_button("Revenir à mon compte")
    end

    it "includes the impersonated user email in the message" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_text(impersonated_user.email)
    end
  end

  describe "route dependencies" do
    it "uses the correct stop_impersonating route" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_button("Revenir à mon compte")
      # Verify the form posts to the correct path
      expect(page).to have_css("form[action='/stop_impersonating'][method='post']")
    end
  end

  describe "icon rendering" do
    it "renders the exclamation-triangle icon" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      # Icon should be rendered via Foundation::IconComponent
      expect(page).to have_css("svg")
    end

    it "icon is decorative and hidden from screen readers" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_css('svg[aria-hidden="true"]')
    end
  end

  describe "styling classes" do
    it "applies yellow warning color scheme" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_css(".bg-yellow-500.text-yellow-900")
    end

    it "applies button styling classes" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_css(".bg-yellow-100.text-yellow-900")
      expect(page).to have_css(".border-yellow-600")
    end

    it "includes responsive container classes" do
      render_inline(described_class.new(true_user: super_admin, impersonated_user: impersonated_user))

      expect(page).to have_css(".max-w-7xl")
      expect(page).to have_css(".mx-auto")
    end
  end
end
