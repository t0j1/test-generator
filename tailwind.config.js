/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      // 1. 配色の定義
      colors: {
        // メインカラー：ヘッダー背景や主要なボタンに使用
        primary: {
          DEFAULT: '#2196f3', // 鮮やかな青色（Material Design Blue 500）
          hover: '#1976d2',    // ホバー時用に少し濃い色（Blue 700）
          light: '#e3f2fd',    // 背景の装飾などに使えるごく薄い青（Blue 50）
          dark: '#1565c0',     // より濃い青（Blue 800）
        },
        // アクセントカラー：イラストや強調表現に使用
        accent: {
          yellow: '#ffd54f',   // イラストの本の黄色（Amber 300）
          blue: '#90caf9',     // イラストの本の水色（Blue 300）
          green: '#81c784',    // イラストの本の黄緑色（Green 300）
          orange: '#ffb74d',   // オレンジ色（Orange 300）
        },
        // テキストカラー：可読性を考慮した濃いグレー
        text: {
          main: '#1a1a2e',     // メインテキスト（濃紺）
          sub: '#52527a',      // サブテキスト（紫がかったグレー）
          light: '#9ca3af',    // 薄いグレー
          inverse: '#ffffff',  // ボタン内などの白文字
        },
        // 背景色
        bg: {
          main: '#ffffff',     // メイン背景の白
          sub: '#f8fafc',      // わずかにグレーがかった背景
          light: '#e3f2fd',    // 薄い青の背景
          gradient: {
            start: '#e3f2fd',  // グラデーション開始色
            end: '#bbdefb',    // グラデーション終了色
          }
        },
        // Glassmorphism用の色
        glass: {
          white: 'rgba(255, 255, 255, 0.18)',
          'white-strong': 'rgba(255, 255, 255, 0.28)',
          border: 'rgba(255, 255, 255, 0.35)',
          shadow: 'rgba(0, 0, 0, 0.15)',
        },
        // Neumorphism用の影
        neo: {
          'shadow-light': 'rgba(255, 255, 255, 0.9)',
          'shadow-dark': 'rgba(150, 170, 190, 0.4)',
        }
      },

      // 2. フォントファミリーの定義
      fontFamily: {
        sans: [
          '"Noto Sans JP"',
          '"Hiragino Kaku Gothic ProN"',
          '"Hiragino Sans"',
          'Meiryo',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          'sans-serif',
        ],
        display: [
          '"Noto Sans JP"',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          'sans-serif',
        ],
      },

      // 3. 角丸の定義
      borderRadius: {
        'pill': '9999px',     // 完全な角丸（スタートボタン用）
        'card': '1.5rem',     // 24px - カードUI用
        'xl': '2rem',         // 32px - 大きな角丸
        '2xl': '2.5rem',      // 40px - 非常に大きな角丸
        'kiosk': '1.75rem',   // 28px - キオスクUI用
      },

      // 4. 影の定義
      boxShadow: {
        'primary-btn': '0 12px 32px rgba(33, 150, 243, 0.4)',
        'glass': '0 8px 32px rgba(0, 0, 0, 0.15)',
        'glass-hover': '0 16px 48px rgba(0, 0, 0, 0.25)',
        'neo': '6px 6px 14px rgba(150, 170, 190, 0.4), -6px -6px 14px rgba(255, 255, 255, 0.9)',
        'neo-hover': '8px 8px 16px rgba(150, 170, 190, 0.4), -8px -8px 16px rgba(255, 255, 255, 0.9)',
        'neo-inset': 'inset 4px 4px 12px rgba(150, 170, 190, 0.4), inset -4px -4px 12px rgba(255, 255, 255, 0.9)',
      },

      // 5. トランジション
      transitionDuration: {
        '260': '260ms',
      },
      transitionTimingFunction: {
        'kiosk': 'cubic-bezier(0.23, 1, 0.32, 1)',
      },

      // 6. スペーシング
      spacing: {
        '18': '4.5rem',  // 72px
        '22': '5.5rem',  // 88px
      },

      // 7. バックドロップフィルター
      backdropBlur: {
        'kiosk': '22px',
      },
    },
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
