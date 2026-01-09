# frozen_string_literal: true

# Display::TimeagoComponent
#
# A component that displays relative time (e.g., "3 hours ago", "in 2 days").
# Automatically updates in the browser using a Stimulus controller.
# Falls back to a static time_ago_in_words when JavaScript is disabled.
# Supports i18n for multiple languages.
#
# @example Basic usage
#   <%= render Display::TimeagoComponent.new(datetime: post.created_at) %>
#
# @example With custom prefix
#   <%= render Display::TimeagoComponent.new(datetime: event.starts_at, prefix: "Starts") %>
#   # Output: "Starts in 2 hours"
#
# @example With custom suffix
#   <%= render Display::TimeagoComponent.new(datetime: post.updated_at, suffix: "modified") %>
#   # Output: "3 days modified"
#
# @example Without auto-update
#   <%= render Display::TimeagoComponent.new(datetime: log.timestamp, auto_update: false) %>
#
# @example With live indicator
#   <%= render Display::TimeagoComponent.new(datetime: comment.created_at, live_indicator: true) %>
#
# @example Future dates
#   <%= render Display::TimeagoComponent.new(datetime: 2.hours.from_now) %>
#   # Output: "in 2 hours"
#
# @example Custom refresh interval
#   <%= render Display::TimeagoComponent.new(datetime: event.created_at, refresh_interval: 60000) %>
#
# @see Display::TimeagoComponentPreview Lookbook previews
class Display::TimeagoComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Default refresh interval in milliseconds (1 minute)
  DEFAULT_REFRESH_INTERVAL = 60_000

  # Minimum refresh interval in milliseconds (10 seconds)
  MIN_REFRESH_INTERVAL = 10_000

  # Maximum refresh interval in milliseconds (1 hour)
  MAX_REFRESH_INTERVAL = 3_600_000

  # @param datetime [Time, DateTime, ActiveSupport::TimeWithZone] The datetime to display
  # @param auto_update [Boolean] Whether to auto-update the display (requires JavaScript)
  # @param refresh_interval [Integer] Interval in milliseconds between updates (default: 60000)
  # @param prefix [String, nil] Custom prefix (e.g., "Posted", "Updated")
  # @param suffix [String] Custom suffix (default: "ago" for past, none for future)
  # @param show_title [Boolean] Whether to show full datetime in title attribute on hover
  # @param title_format [String] strftime format for the title attribute
  # @param live_indicator [Boolean] Whether to show a live update indicator
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    datetime:,
    auto_update: true,
    refresh_interval: DEFAULT_REFRESH_INTERVAL,
    prefix: nil,
    suffix: nil,
    show_title: true,
    title_format: "%B %d, %Y at %I:%M %p",
    live_indicator: false,
    **html_attributes
  )
    @datetime = datetime
    @auto_update = auto_update
    @refresh_interval = clamp_refresh_interval(refresh_interval)
    @prefix = sanitize_text_input(prefix)
    @suffix = sanitize_text_input(suffix)
    @show_title = show_title
    @title_format = title_format
    @live_indicator = live_indicator
    @html_attributes = html_attributes
  end

  # Check if component should render
  # @return [Boolean]
  def render?
    @datetime.present?
  end

  private

  def clamp_refresh_interval(interval)
    [ [ interval.to_i, MIN_REFRESH_INTERVAL ].max, MAX_REFRESH_INTERVAL ].min
  end

  def sanitize_text_input(text, max_length: 100)
    return nil if text.blank?

    text.to_s.strip.truncate(max_length, omission: "...")
  end

  def timeago_classes
    classes = [ "timeago", "inline-flex", "items-center", "gap-1" ]
    classes << "text-gray-600" unless @html_attributes[:class]&.match?(/text-/)
    classes.compact.join(" ")
  end

  def computed_classes
    custom_class = @html_attributes[:class]
    [ timeago_classes, custom_class ].compact.join(" ")
  end

  def controller_data
    return {} unless @auto_update

    {
      data: {
        controller: "components--timeago",
        "components--timeago-datetime-value": iso8601_datetime,
        "components--timeago-refresh-value": @refresh_interval,
        "components--timeago-prefix-value": @prefix.to_s,
        "components--timeago-suffix-value": formatted_suffix,
        "components--timeago-translations-value": translations_json
      }
    }
  end

  def merged_html_attributes
    default_attrs = controller_data
    attrs = @html_attributes.except(:class)

    if @show_title
      attrs[:title] = formatted_title
    end

    # Add ARIA attributes for accessibility when auto-updating
    if @auto_update
      attrs[:role] = "timer"
      attrs[:aria] ||= {}
      attrs[:aria][:live] = "polite"
      attrs[:aria][:atomic] = "true"
    end

    default_attrs.deep_merge(attrs)
  end

  def iso8601_datetime
    @datetime.iso8601
  end

  def formatted_title
    I18n.l(@datetime, format: @title_format)
  rescue I18n::MissingTranslationData
    @datetime.strftime(@title_format)
  end

  def formatted_suffix
    return @suffix if @suffix.present?

    past? ? t_component("ago", default: "ago") : ""
  end

  def past?
    @datetime < Time.current
  end

  def future?
    @datetime > Time.current
  end

  def relative_time_text
    if future?
      future_time_text
    else
      past_time_text
    end
  end

  def future_time_text
    text = helpers.time_ago_in_words(@datetime)
    parts = []
    parts << @prefix if @prefix.present?
    parts << t_component("in_prefix", default: "in")
    parts << text
    parts << @suffix if @suffix.present?
    parts.compact_blank.join(" ")
  end

  def past_time_text
    text = helpers.time_ago_in_words(@datetime)
    ago_prefix = t_component("ago_prefix", default: "")
    has_ago_prefix = ago_prefix.present?
    parts = []
    parts << @prefix if @prefix.present?
    parts << ago_prefix if has_ago_prefix
    parts << text
    # Only add suffix if there's no ago_prefix (e.g., English uses "ago" suffix, French uses "il y a" prefix)
    parts << formatted_suffix if formatted_suffix.present? && !has_ago_prefix
    parts.compact_blank.join(" ")
  end

  def datetime_attribute
    @datetime.respond_to?(:iso8601) ? @datetime.iso8601 : @datetime.to_s
  end

  def text_target
    @auto_update ? { data: { "components--timeago-target": "text" } } : {}
  end

  def live_indicator_attributes
    return {} unless @live_indicator

    {
      role: "img",
      "aria-label": t_component("live_indicator_label", default: "Live updating")
    }
  end

  def translations_json
    @translations_json ||= build_translations_hash.to_json
  end

  def build_translations_hash
    {
      ago: t_component("ago", default: "ago"),
      ago_prefix: t_component("ago_prefix", default: ""),
      in_prefix: t_component("in_prefix", default: "in"),
      less_than_a_minute: t_component("less_than_a_minute", default: "less than a minute"),
      one_minute: t_component("one_minute", default: "1 minute"),
      x_minutes: t_component("x_minutes", default: "%{count} minutes"),
      about_one_hour: t_component("about_one_hour", default: "about 1 hour"),
      about_x_hours: t_component("about_x_hours", default: "about %{count} hours"),
      one_day: t_component("one_day", default: "1 day"),
      x_days: t_component("x_days", default: "%{count} days"),
      about_one_week: t_component("about_one_week", default: "about 1 week"),
      about_x_weeks: t_component("about_x_weeks", default: "about %{count} weeks"),
      about_one_month: t_component("about_one_month", default: "about 1 month"),
      about_x_months: t_component("about_x_months", default: "about %{count} months"),
      about_one_year: t_component("about_one_year", default: "about 1 year"),
      about_x_years: t_component("about_x_years", default: "about %{count} years")
    }
  end
end
