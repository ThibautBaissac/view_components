# frozen_string_literal: true

module Admin
  # Admin::ImpersonationBannerComponent
  #
  # Displays a warning banner when a super_admin is impersonating another user.
  # Shows the impersonated user's email and provides a button to stop impersonation.
  #
  # @example Basic usage
  #   <%= render Admin::ImpersonationBannerComponent.new(
  #     true_user: true_user,
  #     impersonated_user: current_user
  #   ) %>
  #
  # @example With custom classes
  #   <%= render Admin::ImpersonationBannerComponent.new(
  #     true_user: true_user,
  #     impersonated_user: current_user,
  #     class: "shadow-lg"
  #   ) %>
  class ImpersonationBannerComponent < ViewComponent::Base
    include HtmlAttributesRendering
    include I18nHelpers

    # @param true_user [User, nil] The original super_admin user (nil if not impersonating)
    #   ASSUMPTION: Caller ensures true_user has permission to impersonate impersonated_user
    # @param impersonated_user [User] The currently impersonated user
    #   ASSUMPTION: Both users belong to the same account/tenant (enforced by Pundit)
    # @param html_attributes [Hash] Additional HTML attributes for the banner container
    def initialize(true_user:, impersonated_user:, **html_attributes)
      @true_user = true_user
      @impersonated_user = impersonated_user
      @html_attributes = html_attributes
    end

    # Only render when impersonating (true_user present AND different from impersonated_user)
    # Also validates that true_user is a super_admin for defense in depth
    def render?
      @true_user.present? &&
        @true_user != @impersonated_user &&
        @true_user.super_admin?
    end

    private

    attr_reader :true_user, :impersonated_user

    # Merged HTML attributes for the banner container
    # @return [Hash] Merged HTML attributes
    def merged_html_attributes
      deep_merge_attributes(
        {
          class: container_classes,
          role: "alert",
          aria: { live: "polite" }
        },
        @html_attributes
      )
    end

    # CSS classes for the banner container
    # @return [String] CSS classes
    def container_classes
      "bg-yellow-500 text-yellow-900"
    end

    # CSS classes for the inner container
    # @return [String] CSS classes
    def inner_container_classes
      "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-2"
    end

    # CSS classes for the content wrapper
    # @return [String] CSS classes
    def content_wrapper_classes
      "flex items-center justify-between flex-wrap gap-2"
    end

    # CSS classes for the message wrapper
    # @return [String] CSS classes
    def message_wrapper_classes
      "flex items-center gap-2"
    end

    # CSS classes for the stop impersonation button
    # @return [String] CSS classes
    def button_classes
      [
        "inline-flex items-center px-3 py-1.5 text-sm font-medium",
        "text-yellow-900 bg-yellow-100",
        "border border-yellow-600 rounded-lg",
        "hover:bg-yellow-200",
        "focus:outline-none focus:ring-2 focus:ring-yellow-600",
        "focus:ring-offset-2 focus:ring-offset-yellow-500",
        "transition-colors"
      ].join(" ")
    end

    # Translated banner message text
    # @return [String] Translated text with user email
    def banner_message
      t_component(
        "message",
        default: "Vous êtes connecté en tant que %{email}",
        email: content_tag(:strong, impersonated_user.email, class: "font-bold")
      )
    end

    # Translated button text
    # @return [String] Translated button text
    def button_text
      t_component("button", default: "Revenir à mon compte")
    end
  end
end
