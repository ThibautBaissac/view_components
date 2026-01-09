import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="components--timeago"
// Automatically updates relative time display at specified intervals
// Supports i18n through translations passed from the server
export default class extends Controller {
  static values = {
    datetime: String,
    refresh: { type: Number, default: 60000 },
    prefix: { type: String, default: "" },
    suffix: { type: String, default: "ago" },
    translations: { type: Object, default: {} }
  }

  static targets = ["text"]

  // Time calculation constants
  static timeConstants = {
    SECONDS_PER_MINUTE: 60,
    MINUTES_PER_HOUR: 60,
    HOURS_PER_DAY: 24,
    DAYS_PER_WEEK: 7
  }

  // Default English translations (fallback)
  static defaultTranslations = {
    ago: "ago",
    ago_prefix: "",
    in_prefix: "in",
    less_than_a_minute: "less than a minute",
    one_minute: "1 minute",
    x_minutes: "%{count} minutes",
    about_one_hour: "about 1 hour",
    about_x_hours: "about %{count} hours",
    one_day: "1 day",
    x_days: "%{count} days",
    about_one_week: "about 1 week",
    about_x_weeks: "about %{count} weeks",
    about_one_month: "about 1 month",
    about_x_months: "about %{count} months",
    about_one_year: "about 1 year",
    about_x_years: "about %{count} years"
  }

  connect() {
    try {
      this.datetime = new Date(this.datetimeValue)

      // Validate that the date is valid
      if (isNaN(this.datetime.getTime())) {
        throw new Error(`Invalid datetime: ${this.datetimeValue}`)
      }

      this.translations = this.mergeTranslations()
      this.update()
      this.startRefresh()
    } catch (error) {
      console.error('[TimeagoController] Error initializing:', error)
      // Fallback: disable auto-updates but keep the component visible
      this.stopRefresh()
    }
  }

  disconnect() {
    this.stopRefresh()
  }

  mergeTranslations() {
    return { ...this.constructor.defaultTranslations, ...this.translationsValue }
  }

  startRefresh() {
    this.refreshTimer = setInterval(() => {
      this.update()
    }, this.refreshValue)
  }

  stopRefresh() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
  }

  update() {
    const text = this.formatRelativeTime()
    if (this.hasTextTarget) {
      this.textTarget.textContent = text
    } else {
      const textNode = this.findTextNode()
      if (textNode) {
        textNode.textContent = text
      }
    }
  }

  findTextNode() {
    return Array.from(this.element.childNodes)
      .find(node => node.nodeType === Node.TEXT_NODE ||
        (node.nodeType === Node.ELEMENT_NODE && node.dataset.componentsTimeagoTarget === 'text'))
  }

  t(key, replacements = {}) {
    let text = this.translations?.[key] ?? this.constructor.defaultTranslations[key] ?? key

    // Replace placeholders like %{count} with actual values
    Object.entries(replacements).forEach(([placeholder, value]) => {
      text = text.replace(new RegExp(`%\\{${placeholder}\\}`, 'g'), value)
    })

    return text
  }

  formatRelativeTime() {
    const now = new Date()
    const diff = now - this.datetime
    const absDiff = Math.abs(diff)
    const isFuture = diff < 0

    const seconds = Math.floor(absDiff / 1000)
    const minutes = Math.floor(seconds / this.constructor.timeConstants.SECONDS_PER_MINUTE)
    const hours = Math.floor(minutes / this.constructor.timeConstants.MINUTES_PER_HOUR)
    const days = Math.floor(hours / this.constructor.timeConstants.HOURS_PER_DAY)
    const weeks = Math.floor(days / this.constructor.timeConstants.DAYS_PER_WEEK)

    // More accurate month/year calculation using date arithmetic
    const { months, years } = this.calculateMonthsAndYears(now, isFuture)

    let relativeText

    if (seconds < 60) {
      relativeText = this.t("less_than_a_minute")
    } else if (minutes === 1) {
      relativeText = this.t("one_minute")
    } else if (minutes < 60) {
      relativeText = this.t("x_minutes", { count: minutes })
    } else if (hours === 1) {
      relativeText = this.t("about_one_hour")
    } else if (hours < 24) {
      relativeText = this.t("about_x_hours", { count: hours })
    } else if (days === 1) {
      relativeText = this.t("one_day")
    } else if (days < 7) {
      relativeText = this.t("x_days", { count: days })
    } else if (weeks === 1) {
      relativeText = this.t("about_one_week")
    } else if (weeks < 4) {
      relativeText = this.t("about_x_weeks", { count: weeks })
    } else if (months === 1) {
      relativeText = this.t("about_one_month")
    } else if (months < 12) {
      relativeText = this.t("about_x_months", { count: months })
    } else if (years === 1) {
      relativeText = this.t("about_one_year")
    } else {
      relativeText = this.t("about_x_years", { count: years })
    }

    return this.buildTimeText(relativeText, isFuture)
  }

  calculateMonthsAndYears(now, isFuture) {
    const dateNow = isFuture ? this.datetime : now
    const dateThen = isFuture ? now : this.datetime

    const yearDiff = dateNow.getFullYear() - dateThen.getFullYear()
    const monthDiff = dateNow.getMonth() - dateThen.getMonth()
    const totalMonths = yearDiff * 12 + monthDiff

    return {
      months: totalMonths,
      years: Math.floor(totalMonths / 12)
    }
  }

  buildTimeText(relativeText, isFuture) {
    const parts = []
    const agoPrefix = this.t("ago_prefix")
    const ago = this.t("ago")
    const inPrefix = this.t("in_prefix")

    if (this.prefixValue) {
      parts.push(this.prefixValue)
    }

    if (isFuture) {
      if (inPrefix) {
        parts.push(inPrefix)
      }
      parts.push(relativeText)
      if (this.suffixValue && this.suffixValue !== ago) {
        parts.push(this.suffixValue)
      }
    } else {
      // For languages like French that use prefix for past (e.g., "il y a 5 minutes")
      if (agoPrefix) {
        parts.push(agoPrefix)
      }
      parts.push(relativeText)
      // Only add suffix if there's no ago_prefix (e.g., English uses "ago" suffix, French uses "il y a" prefix)
      if (this.suffixValue && !agoPrefix) {
        parts.push(this.suffixValue)
      }
    }

    return parts.filter(p => p).join(" ")
  }
}
