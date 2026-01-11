# ViewComponent Library AI Instructions

This is a Rails ViewComponent library with reusable UI components organized by function, integrated with Stimulus controllers for interactivity.

## Architecture

### Component Organization
Components are namespaced by purpose in `app/components/`:
- **foundation/** - Core primitives (buttons, icons, links, tooltips)
- **layout/** - Structural components (cards, modals, tabs, page headers)
- **form/field/** - Form inputs with consistent styling/validation
- **feedback/** - User notifications (alerts, toasts, modals)
- **display/** - Data presentation (badges, stat cards, timeago)
- **navigation/** - Navigation elements (navbars, dropdowns, pagination)
- **behavior/** - Interactive utilities (clipboard)
- **admin/** - Admin-specific components

### Component Inheritance Pattern
Many components inherit from abstract base classes that provide shared functionality:
- `Form::Field::BaseComponent` - Abstract base for all form fields providing labels, hints, errors, sizing, ARIA attributes
- `Foundation::BaseButtonComponent` - Shared button/link styling with variants, sizes, icons, disabled states

When creating form fields, always extend `BaseComponent` and leverage inherited methods.

### Essential Concerns
All components use two key concerns from `app/components/concerns/`:

**`HtmlAttributesRendering`** - Standard HTML attribute rendering:
- Use `tag.attributes(merged_html_attributes)` in templates (preferred Rails way)
- Legacy `html_attributes_string` method available
- Handles nested hashes (data, aria), boolean attributes, XSS escaping
- Pattern: Accept `**html_attributes` in initialize, merge with defaults in `merged_html_attributes` private method

**`I18nHelpers`** - Scoped translations with fallbacks:
- Use `t_component("key", default: "fallback")` for component-scoped translations
- Auto-scopes to `components.component_name.key` (e.g., `components.alert.dismiss`)
- Always provide defaults to prevent missing translation errors
- Translations in `config/locales/components/category/component_name.{en,fr}.yml`

### Stimulus Integration
Each interactive component has a corresponding Stimulus controller:
- Located in `app/javascript/controllers/components/`
- Naming: `{component_name}_controller.js` → registered as `components--{component-name}`
- Example: `clipboard_controller.js` → `data-controller="components--clipboard"`
- Components attach controllers via `merged_html_attributes` method using `data: { controller: "..." }`

## Component Conventions

### Standard Patterns
1. **Whitespace control**: Add `strip_trailing_whitespace` for clean rendering
2. **Validation**: Validate enums (variants, sizes, types) in `initialize` with descriptive errors
3. **Constants**: Define allowed values as frozen constants (e.g., `VARIANTS`, `SIZES`, `TYPES`)
4. **Configuration hashes**: Use config hashes for type-specific styling (see `TYPE_CONFIG` in `AlertComponent`)
5. **Slots**: Use `renders_one` for single slots, `renders_many` for collections
   - Polymorphic slots: `renders_many :items, types: { link: "LinkItem", button: "ButtonItem" }`
6. **Conditional rendering**: Implement `render?` method when component needs rendering logic

### CSS & Styling
- TailwindCSS utility classes throughout
- Build CSS strings in private methods (e.g., `container_classes`, `icon_classes`)
- Use arrays and join for readability: `["base", "variant", custom].compact.join(" ")`
- Escape dots in CSS specs: `"px-2\\.5"` → `expect(page).to have_css(".px-2\\.5")`

### Accessibility
- Include ARIA attributes via `merged_html_attributes` (role, aria-live, aria-describedby)
- For forms: connect labels to inputs, error messages to `aria-describedby`, `aria-invalid` on errors
- Validate accessible names in development (see `BaseButtonComponent` validation)

## Testing

### RSpec Component Tests (`spec/components/`)
- Test file structure mirrors component structure
- Use `render_inline(described_class.new(...))` from ViewComponent test helpers
- Test with Capybara matchers: `expect(page).to have_css(...)`, `expect(page).to have_text(...)`
- Organize into contexts: "rendering", "variants", "accessibility", "validation"
- Test defaults, variants, slots, conditional rendering, i18n
- Example: [spec/components/display/badge_component_spec.rb](spec/components/display/badge_component_spec.rb)

### Preview Components (`test/components/previews/`)
- Inherit from `ViewComponent::Preview`
- Multiple scenarios as public methods with `# @label Comment` annotations
- Access via Rails ViewComponent preview server
- Example: [test/components/previews/foundation/base_button_component_preview.rb](test/components/previews/foundation/base_button_component_preview.rb)

### Running Tests
```bash
bundle exec rspec spec/components/  # Run all component specs
bundle exec rspec spec/components/display/badge_component_spec.rb  # Single file
```

## Creating New Components

### Basic Component Template
```ruby
# frozen_string_literal: true

class Category::NewComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  strip_trailing_whitespace

  VARIANTS = %i[default primary].freeze
  DEFAULT_VARIANT = :default

  def initialize(text:, variant: DEFAULT_VARIANT, **html_attributes)
    @text = text
    @variant = variant.to_sym
    @html_attributes = html_attributes

    validate_variant!
  end

  private

  def validate_variant!
    return if VARIANTS.include?(@variant)
    raise ArgumentError, "Invalid variant: #{@variant}. Valid variants: #{VARIANTS.join(', ')}"
  end

  def merged_html_attributes
    { class: container_classes }.merge(@html_attributes.except(:class))
  end

  def container_classes
    custom_class = @html_attributes[:class]
    ["base-classes", variant_classes, custom_class].compact.join(" ")
  end

  def variant_classes
    case @variant
    when :primary then "bg-blue-500"
    when :default then "bg-gray-100"
    end
  end
end
```

### With Stimulus Controller
Add controller data in `merged_html_attributes`:
```ruby
def merged_html_attributes
  default_attrs = {
    data: {
      controller: "components--new-component",
      components__new_component_option_value: @option
    }
  }
  default_attrs.deep_merge(@html_attributes)
end
```

## Key Files to Reference
- Component base patterns: [app/components/foundation/base_button_component.rb](app/components/foundation/base_button_component.rb)
- Form field architecture: [app/components/form/field/base_component.rb](app/components/form/field/base_component.rb)
- Slots pattern: [app/components/navigation/dropdown_menu_component.rb](app/components/navigation/dropdown_menu_component.rb)
- Configuration hashes: [app/components/feedback/alert_component.rb](app/components/feedback/alert_component.rb)
- Stimulus integration: [app/components/behavior/clipboard_component.rb](app/components/behavior/clipboard_component.rb) + [app/javascript/controllers/components/clipboard_controller.js](app/javascript/controllers/components/clipboard_controller.js)
