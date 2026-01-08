# frozen_string_literal: true

module Admin
  # @label Impersonation Banner
  # @display bg_color "#f5f5f5"
  class ImpersonationBannerPreview < ViewComponent::Preview
    # Default impersonation banner showing when a super_admin is impersonating another user.
    # Displays the impersonated user's email and a button to stop impersonating.
    #
    # @label Default
    def default
      render Admin::ImpersonationBannerComponent.new(
        true_user: super_admin,
        impersonated_user: regular_user
      )
    end

    # Banner with a very long email address to test text wrapping behavior.
    # The banner should handle long emails gracefully with proper responsive wrapping.
    #
    # @label Long Email
    def long_email
      long_email_user = User.new(
        id: 999,
        email: "very.long.email.address.that.might.wrap.on.smaller.screens@eventessentials.fr",
        role: :planner,
        account: Account.new(id: 1, name: "Test Account")
      )
      long_email_user.define_singleton_method(:super_admin?) { false }

      render Admin::ImpersonationBannerComponent.new(
        true_user: super_admin,
        impersonated_user: long_email_user
      )
    end

    # Banner with custom styling applied via HTML attributes.
    # Shows how the component can be extended with additional classes.
    #
    # @label Custom Styling
    def custom_styling
      render Admin::ImpersonationBannerComponent.new(
        true_user: super_admin,
        impersonated_user: regular_user,
        class: "shadow-lg border-2 border-yellow-600"
      )
    end

    # Banner with custom data attributes for testing JavaScript integration.
    # Useful for testing Stimulus controllers or other JavaScript enhancements.
    #
    # @label With Data Attributes
    def with_data_attributes
      render Admin::ImpersonationBannerComponent.new(
        true_user: super_admin,
        impersonated_user: regular_user,
        data: {
          controller: "test-controller",
          testid: "impersonation-banner"
        }
      )
    end

    # This scenario should not render anything because true_user is nil.
    # Demonstrates the conditional rendering behavior.
    #
    # @label Not Impersonating (No Render)
    def not_impersonating
      render Admin::ImpersonationBannerComponent.new(
        true_user: nil,
        impersonated_user: regular_user
      )
    end

    # This scenario should not render anything because true_user is not a super_admin.
    # Demonstrates the authorization check in the render? method.
    #
    # @label Non Super Admin (No Render)
    def non_super_admin
      render Admin::ImpersonationBannerComponent.new(
        true_user: regular_user,
        impersonated_user: another_user
      )
    end

    private

    # Create a mock super_admin user for previews
    # @return [User]
    def super_admin
      user = User.new(
        id: 1,
        email: "admin@eventessentials.fr",
        role: :super_admin,
        account: Account.new(id: 1, name: "Admin Account")
      )
      user.define_singleton_method(:super_admin?) { true }
      user
    end

    # Create a mock regular user (planner) for previews
    # @return [User]
    def regular_user
      user = User.new(
        id: 2,
        email: "planner@example.com",
        role: :planner,
        account: Account.new(id: 1, name: "Test Account")
      )
      user.define_singleton_method(:super_admin?) { false }
      user
    end

    # Create another mock regular user for testing
    # @return [User]
    def another_user
      user = User.new(
        id: 3,
        email: "another.planner@example.com",
        role: :planner,
        account: Account.new(id: 1, name: "Test Account")
      )
      user.define_singleton_method(:super_admin?) { false }
      user
    end
  end
end
