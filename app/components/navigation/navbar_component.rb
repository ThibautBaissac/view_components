# frozen_string_literal: true

module Navigation
  # NavbarComponent
  #
  # A responsive navigation bar component with mobile menu support.
  # Uses Stimulus for mobile menu toggle and Tailwind CSS for styling.
  #
  # @example Basic usage
  #   <%= render(Navigation::NavbarComponent.new) do |navbar| %>
  #     <% navbar.with_logo do %>
  #       <%= link_to "EventEssentials", root_path, class: "font-bold text-xl" %>
  #     <% end %>
  #
  #     <% navbar.with_nav_item(text: "Dashboard", url: dashboard_path, active: true) %>
  #     <% navbar.with_nav_item(text: "Events", url: events_path) %>
  #     <% navbar.with_nav_item(text: "Vendors", url: vendors_path) %>
  #
  #     <% navbar.with_action do %>
  #       <%= link_to "Sign out", destroy_user_session_path, method: :delete, class: "btn btn-sm" %>
  #     <% end %>
  #   <% end %>
  #
  class NavbarComponent < ViewComponent::Base
    include HtmlAttributesRendering
    include I18nHelpers

    renders_one :logo
    renders_many :nav_items, "NavItemComponent"
    renders_many :actions

    # @param variant [Symbol] Style variant (:default, :dark, :transparent)
    # @param sticky [Boolean] Whether navbar should be sticky on scroll
    # @param html_attributes [Hash] Additional HTML attributes
    def initialize(variant: :default, sticky: false, **html_attributes)
      @variant = variant
      @sticky = sticky
      @html_attributes = html_attributes
    end

    # Translated text for mobile menu button
    def mobile_menu_label
      t_component("mobile_menu_label", default: "Open main menu")
    end

    private

    def navbar_classes
      base = "border-b"
      classes = [ base ]

      classes << variant_classes
      classes << "sticky top-0 z-50" if @sticky

      classes.join(" ")
    end

    def variant_classes
      case @variant
      when :dark
        "bg-gray-900 text-white border-gray-800"
      when :transparent
        "bg-transparent"
      else
        "bg-white text-gray-900 border-gray-200"
      end
    end

    def controller_data
      {
        controller: "components--navbar",
        action: "resize@window->components--navbar#handleResize"
      }
    end

    def attributes_for_rendering
      default_attrs = {
        class: navbar_classes,
        data: controller_data
      }

      deep_merge_attributes(default_attrs, @html_attributes)
    end

    # NavItemComponent
    #
    # Individual navigation item for the navbar
    class NavItemComponent < ViewComponent::Base
      include HtmlAttributesRendering

      # @param text [String] Link text
      # @param url [String] Link URL
      # @param active [Boolean] Whether this item is active
      # @param resource_color [Symbol, nil] Optional resource color (:amber, :rose, :emerald)
      # @param html_attributes [Hash] Additional HTML attributes
      def initialize(text:, url:, active: false, resource_color: nil, **html_attributes)
        @text = text
        @url = url
        @active = active
        @resource_color = resource_color
        @html_attributes = html_attributes
      end

      def call
        link_to @text, @url, **link_attributes
      end

      private

      def link_attributes
        attrs = {
          class: item_classes
        }

        attrs[:"aria-current"] = "page" if @active

        attrs.merge(@html_attributes)
      end

      def item_classes
        base = "px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200"

        if @active
          active_classes = @resource_color.present? ? resource_active_classes : default_active_classes
          [ base, active_classes ].join(" ")
        else
          inactive = "text-slate-700 hover:bg-slate-100 hover:text-slate-900"
          [ base, inactive ].join(" ")
        end
      end

      def default_active_classes
        "bg-slate-100 text-slate-700"
      end

      def resource_active_classes
        case @resource_color
        when :amber
          "bg-amber-50 text-amber-700"
        when :rose
          "bg-rose-50 text-rose-700"
        when :emerald
          "bg-emerald-50 text-emerald-700"
        else
          default_active_classes
        end
      end
    end
  end
end
