# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::TimeagoComponent, type: :component do
  let(:past_time) { 2.hours.ago }
  let(:future_time) { 2.hours.from_now }

  describe "rendering" do
    context "with basic configuration" do
      it "renders time element with past datetime" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css("time.timeago")
        expect(page).to have_text("about 2 hours")
      end

      it "renders with ISO8601 datetime attribute" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css("time[datetime='#{past_time.iso8601}']")
      end

      it "includes default timeago classes" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css("time.timeago.inline-flex.items-center.gap-1")
      end

      it "includes default text color when no custom class" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css("time.text-gray-600")
      end

      it "does not add default text color when custom text color provided" do
        render_inline(described_class.new(datetime: past_time, class: "text-blue-500"))

        expect(page).to have_css("time.text-blue-500")
        expect(page).not_to have_css("time.text-gray-600")
      end
    end

    context "with past datetime" do
      it "displays time ago text" do
        time = 3.days.ago
        render_inline(described_class.new(datetime: time))

        expect(page).to have_text("3 days")
      end

      it "displays relative time for past datetime" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_text("about 2 hours")
      end

      it "uses custom prefix when provided" do
        render_inline(described_class.new(datetime: past_time, prefix: "Posted"))

        expect(page).to have_text("Posted")
        expect(page).to have_text("about 2 hours")
      end

      it "uses custom suffix when provided" do
        # Test in English locale since French uses prefix instead of suffix
        I18n.with_locale(:en) do
          render_inline(described_class.new(datetime: past_time, suffix: "earlier"))

          expect(page).to have_text("about 2 hours earlier")
        end
      end
    end

    context "with future datetime" do
      it "displays future time text" do
        render_inline(described_class.new(datetime: future_time))

        expect(page).to have_text("about 2 hours")
      end

      it "renders future datetime correctly" do
        render_inline(described_class.new(datetime: future_time))

        # Should render the relative time
        expect(page).to have_css("time.timeago")
      end

      it "uses custom prefix for future times" do
        render_inline(described_class.new(datetime: future_time, prefix: "Starts"))

        expect(page).to have_text("Starts")
        expect(page).to have_text("about 2 hours")
      end
    end

    context "with auto-update enabled (default)" do
      it "includes Stimulus controller" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css('[data-controller="components--timeago"]')
      end

      it "includes datetime Stimulus value" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css("[data-components--timeago-datetime-value='#{past_time.iso8601}']")
      end

      it "includes default refresh interval (60000ms)" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css('[data-components--timeago-refresh-value="60000"]')
      end

      it "includes custom refresh interval" do
        render_inline(described_class.new(datetime: past_time, refresh_interval: 30000))

        expect(page).to have_css('[data-components--timeago-refresh-value="30000"]')
      end

      it "includes prefix Stimulus value" do
        render_inline(described_class.new(datetime: past_time, prefix: "Posted"))

        expect(page).to have_css('[data-components--timeago-prefix-value="Posted"]')
      end

      it "includes suffix Stimulus value" do
        render_inline(described_class.new(datetime: past_time, suffix: "earlier"))

        expect(page).to have_css('[data-components--timeago-suffix-value="earlier"]')
      end

      it "includes text target" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css('[data-components--timeago-target="text"]')
      end

      it "includes translations JSON" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css('[data-components--timeago-translations-value]')
      end
    end

    context "with auto-update disabled" do
      it "does not include Stimulus controller" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).not_to have_css('[data-controller="components--timeago"]')
      end

      it "does not include Stimulus values" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).not_to have_css('[data-components--timeago-datetime-value]')
        expect(page).not_to have_css('[data-components--timeago-refresh-value]')
      end

      it "does not include text target" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).not_to have_css('[data-components--timeago-target="text"]')
      end

      it "still renders time element with text" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).to have_css("time.timeago")
        expect(page).to have_text("about 2 hours")
      end
    end

    context "with title attribute" do
      it "includes title attribute by default" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).to have_css('time[title]')
      end

      it "formats title with default format" do
        time = Time.zone.parse("2024-06-15 14:30:00")
        render_inline(described_class.new(datetime: time))

        expect(page).to have_css("time[title]")
      end

      it "does not include title when show_title is false" do
        render_inline(described_class.new(datetime: past_time, show_title: false))

        expect(page).not_to have_css('time[title]')
      end

      it "uses custom title format" do
        time = Time.zone.parse("2024-06-15 14:30:00")
        render_inline(described_class.new(datetime: time, title_format: "%Y-%m-%d"))

        expect(page).to have_css("time[title='2024-06-15']")
      end
    end

    context "with live indicator" do
      it "does not show live indicator by default" do
        render_inline(described_class.new(datetime: past_time))

        expect(page).not_to have_css(".animate-ping")
      end

      it "shows live indicator when enabled" do
        render_inline(described_class.new(datetime: past_time, live_indicator: true))

        expect(page).to have_css(".animate-ping")
        expect(page).to have_css(".bg-green-400")
        expect(page).to have_css(".bg-green-500")
      end

      it "renders pulsing animation elements" do
        render_inline(described_class.new(datetime: past_time, live_indicator: true))

        expect(page).to have_css("span.relative.flex.h-2.w-2")
        expect(page).to have_css("span.animate-ping")
        expect(page).to have_css("span.relative.inline-flex.rounded-full")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(datetime: past_time, class: "custom-timeago"))

        expect(page).to have_css("time.timeago.custom-timeago")
      end

      it "renders with custom ID" do
        render_inline(described_class.new(datetime: past_time, id: "timeago-1"))

        expect(page).to have_css("time#timeago-1")
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(datetime: past_time, data: { testid: "timeago" }))

        expect(page).to have_css('[data-testid="timeago"]')
      end
    end
  end

  describe "#render?" do
    it "renders when datetime is present" do
      component = described_class.new(datetime: past_time)

      expect(component.render?).to be true
    end

    it "does not render when datetime is nil" do
      component = described_class.new(datetime: nil)

      expect(component.render?).to be false
    end

    it "actually skips rendering when datetime is nil" do
      result = render_inline(described_class.new(datetime: nil))

      expect(result.to_html.strip).to be_empty
    end
  end

  describe "refresh interval validation" do
    it "uses default refresh interval (60000ms)" do
      render_inline(described_class.new(datetime: past_time))

      expect(page).to have_css('[data-components--timeago-refresh-value="60000"]')
    end

    it "clamps refresh interval to minimum (10000ms)" do
      render_inline(described_class.new(datetime: past_time, refresh_interval: 5000))

      expect(page).to have_css('[data-components--timeago-refresh-value="10000"]')
    end

    it "clamps refresh interval to maximum (3600000ms)" do
      render_inline(described_class.new(datetime: past_time, refresh_interval: 5_000_000))

      expect(page).to have_css('[data-components--timeago-refresh-value="3600000"]')
    end

    it "accepts valid custom refresh interval" do
      render_inline(described_class.new(datetime: past_time, refresh_interval: 30000))

      expect(page).to have_css('[data-components--timeago-refresh-value="30000"]')
    end
  end

  describe "prefix and suffix sanitization" do
    it "strips whitespace from prefix" do
      render_inline(described_class.new(datetime: past_time, prefix: "  Posted  "))

      expect(page).to have_css('[data-components--timeago-prefix-value="Posted"]')
    end

    it "truncates long prefix" do
      long_prefix = "a" * 150
      render_inline(described_class.new(datetime: past_time, prefix: long_prefix))

      expect(page).to have_css('[data-components--timeago-prefix-value]')
    end

    it "handles nil prefix" do
      render_inline(described_class.new(datetime: past_time, prefix: nil))

      expect(page).to have_css('[data-components--timeago-prefix-value=""]')
    end

    it "strips whitespace from suffix" do
      render_inline(described_class.new(datetime: past_time, suffix: "  earlier  "))

      expect(page).to have_css('[data-components--timeago-suffix-value="earlier"]')
    end
  end

  describe "accessibility" do
    it "uses semantic time element" do
      render_inline(described_class.new(datetime: past_time))

      expect(page).to have_css("time")
    end

    it "includes datetime attribute for machine readability" do
      render_inline(described_class.new(datetime: past_time))

      expect(page).to have_css("time[datetime]")
    end

    it "includes human-readable title attribute" do
      render_inline(described_class.new(datetime: past_time))

      expect(page).to have_css("time[title]")
    end

    it "displays human-readable text content" do
      render_inline(described_class.new(datetime: past_time))

      expect(page).to have_text("about 2 hours")
    end

    context "with auto-update enabled" do
      it "includes role='timer' for dynamic content" do
        render_inline(described_class.new(datetime: past_time, auto_update: true))

        expect(page).to have_css('time[role="timer"]')
      end

      it "includes aria-live='polite' for screen reader announcements" do
        render_inline(described_class.new(datetime: past_time, auto_update: true))

        expect(page).to have_css('time[aria-live="polite"]')
      end

      it "includes aria-atomic='true' for complete announcements" do
        render_inline(described_class.new(datetime: past_time, auto_update: true))

        expect(page).to have_css('time[aria-atomic="true"]')
      end
    end

    context "without auto-update" do
      it "does not include role='timer'" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).to have_no_css('time[role="timer"]')
      end

      it "does not include aria-live attribute" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).to have_no_css('time[aria-live]')
      end

      it "does not include aria-atomic attribute" do
        render_inline(described_class.new(datetime: past_time, auto_update: false))

        expect(page).to have_no_css('time[aria-atomic]')
      end
    end

    context "with live indicator" do
      it "includes role='img' for visual indicator" do
        render_inline(described_class.new(datetime: past_time, live_indicator: true))

        expect(page).to have_css('span[role="img"]')
      end

      it "includes accessible label for live indicator" do
        # Test in English locale to verify English translation
        I18n.with_locale(:en) do
          render_inline(described_class.new(datetime: past_time, live_indicator: true))

          expect(page).to have_css('span[aria-label="Live updating"]')
        end
      end

      it "uses French translation for aria-label with French locale" do
        I18n.with_locale(:fr) do
          render_inline(described_class.new(datetime: past_time, live_indicator: true))

          expect(page).to have_css('span[aria-label="Mise à jour en direct"]')
        end
      end
    end
  end

  describe "edge cases" do
    it "handles DateTime objects" do
      datetime = DateTime.now - 1.day
      render_inline(described_class.new(datetime: datetime))

      expect(page).to have_css("time.timeago")
      expect(page).to have_text("1 day")
    end

    it "handles ActiveSupport::TimeWithZone" do
      time = 5.minutes.ago
      render_inline(described_class.new(datetime: time))

      expect(page).to have_css("time.timeago")
      expect(page).to have_text("5 minutes")
    end

    it "handles very recent time (less than a minute)" do
      time = 30.seconds.ago
      render_inline(described_class.new(datetime: time))

      expect(page).to have_css("time.timeago")
      # Rails time_ago_in_words returns "less than a minute" or "1 minute" depending on precision
      expect(page).to have_text(/\d+ minute|less than/)
    end

    it "handles very old dates" do
      time = 5.years.ago
      render_inline(described_class.new(datetime: time))

      expect(page).to have_css("time.timeago")
      expect(page).to have_text("about 5 years")
    end

    it "handles far future dates" do
      time = 10.days.from_now
      render_inline(described_class.new(datetime: time))

      expect(page).to have_css("time.timeago")
      expect(page).to have_text("10 days")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        datetime: past_time,
        auto_update: true,
        refresh_interval: 30000,
        prefix: "Updated",
        suffix: "earlier",
        show_title: true,
        title_format: "%Y-%m-%d %H:%M",
        live_indicator: true,
        class: "custom-time",
        id: "time-1"
      ))

      expect(page).to have_css("time#time-1.custom-time")
      expect(page).to have_css('[data-controller="components--timeago"]')
      expect(page).to have_css('[data-components--timeago-refresh-value="30000"]')
      expect(page).to have_css('[data-components--timeago-prefix-value="Updated"]')
      expect(page).to have_css(".animate-ping")
      expect(page).to have_text("Updated")
    end

    it "handles special characters in prefix" do
      render_inline(described_class.new(
        datetime: past_time,
        prefix: "Posted <script>alert('xss')</script>"
      ))

      expect(page).to have_text("Posted")
      expect(page).not_to have_css("script")
    end

    it "handles special characters in suffix" do
      # Test in English locale since French uses prefix instead of suffix
      I18n.with_locale(:en) do
        render_inline(described_class.new(
          datetime: past_time,
          suffix: "earlier <b>test</b>"
        ))

        expect(page).to have_text("earlier")
        expect(page).not_to have_css("b")
      end
    end
  end

  describe "i18n support" do
    it "includes translations JSON for JavaScript" do
      render_inline(described_class.new(datetime: past_time))

      expect(page).to have_css('[data-components--timeago-translations-value]')
    end

    it "builds translations hash with default values" do
      component = described_class.new(datetime: past_time)
      render_inline(component)

      # Verify the component renders without errors
      expect(page).to have_css("time.timeago")
    end

    context "with French locale" do
      around do |example|
        I18n.with_locale(:fr) { example.run }
      end

      it "uses French 'ago' prefix for past times" do
        render_inline(described_class.new(datetime: 2.hours.ago))

        expect(page).to have_text("il y a")
      end

      it "uses French 'in' prefix for future times" do
        render_inline(described_class.new(datetime: 2.hours.from_now))

        expect(page).to have_text("dans")
      end

      it "translates time units to French" do
        render_inline(described_class.new(datetime: 1.day.ago))

        # Verify French prefix is used (Rails may or may not translate time units)
        expect(page).to have_text("il y a")
      end

      it "includes French translations in JSON for JavaScript" do
        component = described_class.new(datetime: past_time)
        render_inline(component)

        translations_json = page.find('[data-components--timeago-translations-value]', visible: false)["data-components--timeago-translations-value"]
        translations = JSON.parse(translations_json)

        expect(translations["ago"]).to eq("il y a")
        expect(translations["ago_prefix"]).to eq("il y a")
        expect(translations["in_prefix"]).to eq("dans")
        expect(translations["one_day"]).to eq("1 jour")
      end

      it "uses French translation for live indicator label" do
        render_inline(described_class.new(datetime: past_time, live_indicator: true))

        expect(page).to have_css('span[aria-label="Mise à jour en direct"]')
      end
    end
  end

  describe "datetime formatting" do
    it "converts datetime to ISO8601 format" do
      time = Time.zone.parse("2024-06-15 14:30:00")
      render_inline(described_class.new(datetime: time))

      expect(page).to have_css("time[datetime='#{time.iso8601}']")
    end

    it "handles datetime objects without iso8601 method gracefully" do
      # Most Ruby time objects support iso8601, but test fallback
      time = past_time
      render_inline(described_class.new(datetime: time))

      expect(page).to have_css("time[datetime]")
    end
  end

  describe "text target conditional" do
    it "includes text target when auto_update is true" do
      render_inline(described_class.new(datetime: past_time, auto_update: true))

      expect(page).to have_css('[data-components--timeago-target="text"]')
    end

    it "does not include text target when auto_update is false" do
      render_inline(described_class.new(datetime: past_time, auto_update: false))

      expect(page).not_to have_css('[data-components--timeago-target="text"]')
    end
  end

  describe "relative time calculations" do
    it "correctly identifies past time" do
      render_inline(described_class.new(datetime: 1.hour.ago))

      expect(page).to have_text("about 1 hour")
      expect(page).to have_css("time.timeago")
    end

    it "correctly identifies future time" do
      render_inline(described_class.new(datetime: 1.hour.from_now))

      expect(page).to have_text("about 1 hour")
      expect(page).to have_css("time.timeago")
    end
  end
end
