module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
  // Preserve custom CSS classes from being purged
  safelist: [
    // Kiosk UI classes
    'bg-kiosk',
    'glass-card',
    'glass-card-static',
    'btn-neo',
    'btn-neo-green',
    'btn-neo-orange',
    'btn-neo-secondary',
    'progress-kiosk',
    'progress-step',
    'subject-card',
    'subject-card-icon',
    'subject-card-title',
    'unit-card',
    'unit-card-grade',
    'unit-card-title',
    'unit-card-count',
    'settings-panel',
    'settings-title',
    'setting-item',
    'setting-label',
    'setting-select',
    'option-checkbox-item',
    'option-checkbox',
    'option-label',
    'print-card',
    'print-card-icon',
    'print-card-title',
    'print-card-desc',
    'subject-badge',
    'heading-kiosk-1',
    'heading-kiosk-2',
    'heading-kiosk-3',
    'text-kiosk-body',
    'carousel-kiosk',
    'carousel-item',
    // State classes
    'active',
    'done',
    'selected'
  ],
  // Don't override custom backdrop-filter, box-shadow, etc.
  corePlugins: {
    preflight: true, // Keep Tailwind reset but allow overrides
  }
}
