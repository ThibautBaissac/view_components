# frozen_string_literal: true

# @label Display::Timeago
# @note Displays relative time (e.g., "3 hours ago", "in 2 days") with automatic updates.
#   Perfect for showing when content was created, updated, or will occur.
class Display::TimeagoComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Basic timeago display with auto-updating enabled by default.
  def default
    render(Display::TimeagoComponent.new(datetime: 1.hour.ago))
  end

  # @label Past Times
  # @note Various time intervals in the past, from seconds to years.
  def past_times
    render_with_template(locals: {
      times: [
        { datetime: 30.seconds.ago, label: "30 seconds ago" },
        { datetime: 5.minutes.ago, label: "5 minutes ago" },
        { datetime: 1.hour.ago, label: "1 hour ago" },
        { datetime: 3.hours.ago, label: "3 hours ago" },
        { datetime: 1.day.ago, label: "1 day ago" },
        { datetime: 5.days.ago, label: "5 days ago" },
        { datetime: 2.weeks.ago, label: "2 weeks ago" },
        { datetime: 1.month.ago, label: "1 month ago" },
        { datetime: 6.months.ago, label: "6 months ago" },
        { datetime: 1.year.ago, label: "1 year ago" },
        { datetime: 3.years.ago, label: "3 years ago" }
      ]
    })
  end

  # @label Future Times
  # @note Relative times for future events. Displays as "in X time".
  def future_times
    render_with_template(locals: {
      times: [
        { datetime: 30.seconds.from_now, label: "in 30 seconds" },
        { datetime: 5.minutes.from_now, label: "in 5 minutes" },
        { datetime: 1.hour.from_now, label: "in 1 hour" },
        { datetime: 3.hours.from_now, label: "in 3 hours" },
        { datetime: 1.day.from_now, label: "in 1 day" },
        { datetime: 1.week.from_now, label: "in 1 week" },
        { datetime: 1.month.from_now, label: "in 1 month" }
      ]
    })
  end

  # @label With Prefix
  # @note Add a custom prefix to the time display. Useful for "Posted", "Updated", etc.
  def with_prefix
    render_with_template(locals: {
      examples: [
        { datetime: 2.hours.ago, prefix: "Posted" },
        { datetime: 30.minutes.ago, prefix: "Updated" },
        { datetime: 1.day.ago, prefix: "Created" },
        { datetime: 3.hours.ago, prefix: "Last seen" },
        { datetime: 1.hour.from_now, prefix: "Starts" }
      ]
    })
  end

  # @label With Custom Suffix
  # @note Replace the default "ago" suffix with custom text.
  def with_suffix
    render_with_template(locals: {
      examples: [
        { datetime: 2.hours.ago, suffix: "earlier" },
        { datetime: 30.minutes.ago, suffix: "before deadline" },
        { datetime: 1.day.ago, suffix: "since last login" }
      ]
    })
  end

  # @label With Live Indicator
  # @note Shows a pulsing green dot to indicate real-time updates.
  def with_live_indicator
    render(Display::TimeagoComponent.new(
      datetime: 5.minutes.ago,
      live_indicator: true
    ))
  end

  # @label Without Auto Update
  # @note Static display without JavaScript auto-update. Falls back to Rails time_ago_in_words.
  def without_auto_update
    render(Display::TimeagoComponent.new(
      datetime: 1.hour.ago,
      auto_update: false
    ))
  end

  # @label Without Title
  # @note Hide the title attribute (hover tooltip showing full datetime).
  def without_title
    render(Display::TimeagoComponent.new(
      datetime: 2.hours.ago,
      show_title: false
    ))
  end

  # @label Custom Title Format
  # @note Use a custom strftime format for the title attribute.
  def custom_title_format
    render_with_template(locals: {
      examples: [
        { datetime: 2.hours.ago, title_format: "%Y-%m-%d %H:%M", label: "ISO-like" },
        { datetime: 2.hours.ago, title_format: "%A, %B %d, %Y", label: "Full day name" },
        { datetime: 2.hours.ago, title_format: "%I:%M %p, %b %d", label: "Time first" }
      ]
    })
  end

  # @label Fast Refresh
  # @note Custom refresh interval for more frequent updates (every 10 seconds).
  def fast_refresh
    render(Display::TimeagoComponent.new(
      datetime: Time.current,
      refresh_interval: 10_000,
      live_indicator: true
    ))
  end

  # @label Custom Styling
  # @note Apply custom CSS classes for different visual styles.
  def custom_styling
    render_with_template(locals: {
      examples: [
        { datetime: 1.hour.ago, class: "text-gray-500 text-sm", label: "Muted" },
        { datetime: 2.hours.ago, class: "text-blue-600 font-medium", label: "Primary" },
        { datetime: 3.hours.ago, class: "text-green-600 font-semibold", label: "Success" },
        { datetime: 4.hours.ago, class: "text-red-600 italic", label: "Danger" },
        { datetime: 5.hours.ago, class: "text-purple-600 text-lg", label: "Large" }
      ]
    })
  end

  # @label In Context - Comments
  # @note Example of timeago used in a comment thread.
  def in_context_comments
    render_with_template(locals: {
      comments: [
        { author: "Alice Johnson", avatar: "A", content: "Great work on this feature!", datetime: 5.minutes.ago },
        { author: "Bob Smith", avatar: "B", content: "I have a question about the implementation.", datetime: 2.hours.ago },
        { author: "Carol White", avatar: "C", content: "Thanks for the detailed explanation!", datetime: 1.day.ago }
      ]
    })
  end

  # @label In Context - Activity Feed
  # @note Example of timeago used in an activity feed.
  def in_context_activity_feed
    render_with_template(locals: {
      activities: [
        { action: "Created a new project", datetime: 10.minutes.ago, icon: "folder-plus" },
        { action: "Updated the settings", datetime: 1.hour.ago, icon: "cog-6-tooth" },
        { action: "Invited a team member", datetime: 3.hours.ago, icon: "user-plus" },
        { action: "Published the document", datetime: 1.day.ago, icon: "document-check" }
      ]
    })
  end

  # @label Upcoming Events
  # @note Future dates with prefixes for event listings.
  def upcoming_events
    render_with_template(locals: {
      events: [
        { name: "Team Standup", datetime: 30.minutes.from_now, prefix: "Starts" },
        { name: "Design Review", datetime: 2.hours.from_now, prefix: "Begins" },
        { name: "Sprint Planning", datetime: 1.day.from_now, prefix: "Scheduled" },
        { name: "Release Day", datetime: 1.week.from_now, prefix: "Coming" }
      ]
    })
  end

  # @label French Locale (i18n)
  # @note Example showing French locale support. The component uses "il y a" prefix for past
  #   and "dans" prefix for future times.
  def french_locale
    I18n.with_locale(:fr) do
      render_with_template(locals: {
        times: [
          { datetime: 5.minutes.ago, label: "5 minutes ago (French)" },
          { datetime: 2.hours.ago, label: "2 hours ago (French)" },
          { datetime: 1.day.ago, label: "1 day ago (French)" },
          { datetime: 2.hours.from_now, label: "In 2 hours (French)" }
        ]
      })
    end
  end
end
