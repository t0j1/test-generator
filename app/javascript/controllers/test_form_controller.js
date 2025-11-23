import { Controller } from "@hotwired/stimulus"

// TestSheets#new フォームの動的制御（タブレット最適化版）
export default class extends Controller {
  static targets = [
    "subjectRadio",
    "unitSection",
    "unitList",
    "settingsSection",
    "submitSection",
    "difficultySelect",
    "questionCountSelect",
    "availableInfo",
    "availableCount",
    "submitButton"
  ]

  connect() {
    console.log("✅ TestFormController connected")
    console.log("Targets:", this.constructor.targets)
    this.units = {}
    this.selectedUnitId = null
    this.isSubmitting = false
  }

  // ローディングオーバーレイ表示
  showLoading() {
    const overlay = document.getElementById("loading-overlay")
    if (overlay) {
      overlay.classList.remove("hidden")
    }
  }

  // ローディングオーバーレイ非表示
  hideLoading() {
    const overlay = document.getElementById("loading-overlay")
    if (overlay) {
      overlay.classList.add("hidden")
    }
  }

  // 科目が選択されたとき
  async onSubjectChange(event) {
    const subjectId = event.target.value
    console.log("📌 Subject selected:", subjectId)

    // Step 2（単元選択）を表示
    if (this.hasUnitSectionTarget) {
      console.log("✅ unitSection found, showing...")
      this.unitSectionTarget.classList.remove("hidden")
      
      // スムーズスクロール
      setTimeout(() => {
        this.unitSectionTarget.scrollIntoView({ behavior: "smooth", block: "start" })
      }, 100)
    } else {
      console.error("❌ unitSection target not found")
    }
    
    // Step 3, 4 を非表示
    if (this.hasSettingsSectionTarget) {
      this.settingsSectionTarget.classList.add("hidden")
    }
    if (this.hasSubmitSectionTarget) {
      this.submitSectionTarget.classList.add("hidden")
    }

    await this.loadUnits(subjectId)
  }

  // 単元リストを取得
  async loadUnits(subjectId) {
    console.log("🔄 Loading units for subject:", subjectId)
    
    try {
      // キャッシュがあれば使用
      if (this.units[subjectId]) {
        console.log("💾 Using cached units")
        this.renderUnits(this.units[subjectId])
        return
      }

      // ローディング表示
      this.showLoading()

      // APIから単元データを取得
      console.log("🌐 Fetching units from API...")
      const response = await fetch(`/test_sheets/units_by_subject?subject_id=${subjectId}`)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      console.log("✅ Units loaded:", data)
      
      // キャッシュに保存
      this.units[subjectId] = data.units
      
      // 単元リストをレンダリング
      this.renderUnits(data.units)
      
    } catch (error) {
      console.error("❌ Failed to load units:", error)
      if (this.hasUnitListTarget) {
        this.unitListTarget.innerHTML = `
          <div class="rounded-xl border-2 border-red-200 bg-red-50 p-6 text-center">
            <p class="text-xl font-bold text-red-800 mb-2">単元の読み込みに失敗しました</p>
            <p class="text-base text-red-600">${error.message}</p>
          </div>
        `
      }
    } finally {
      this.hideLoading()
    }
  }

  // 単元をレンダリング（タブレット向け大型ボタン）
  renderUnits(units) {
    console.log("🎨 Rendering units:", units)
    
    if (!this.hasUnitListTarget) {
      console.error("❌ unitList target not found")
      return
    }

    if (!units || units.length === 0) {
      this.unitListTarget.innerHTML = `
        <div class="rounded-xl border-2 border-gray-200 bg-gray-50 p-6 text-center">
          <p class="text-xl text-gray-600">この科目には単元が登録されていません</p>
        </div>
      `
      return
    }

    const html = units.map(unit => `
      <label class="block cursor-pointer touch-manipulation select-none">
        <input 
          type="radio" 
          name="test_sheet[unit_id]" 
          value="${unit.id}" 
          class="peer hidden"
          data-action="change->test-form#onUnitChange"
          data-unit-name="${this.escapeHtml(unit.name)}"
          data-unit-grade="${unit.grade}"
          required
        >
        <div class="
          min-h-24
          rounded-2xl 
          border-4 border-gray-200 
          p-6 
          active:scale-95
          peer-checked:border-8 
          peer-checked:border-blue-500 
          peer-checked:bg-blue-50
          peer-checked:shadow-xl
          transition-all
        ">
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <div class="text-xl md:text-2xl font-bold text-gray-900 mb-1">${this.escapeHtml(unit.name)}</div>
              <div class="text-base md:text-lg text-gray-500">${unit.grade_label}</div>
            </div>
            <div class="text-right ml-4">
              <div class="text-base md:text-lg font-bold text-blue-600">問題数: ${unit.question_count}問</div>
              <div class="mt-2 flex gap-3 text-sm md:text-base text-gray-500">
                <span>易:${unit.question_counts_by_difficulty.easy}</span>
                <span>普:${unit.question_counts_by_difficulty.normal}</span>
                <span>難:${unit.question_counts_by_difficulty.hard}</span>
              </div>
            </div>
          </div>
        </div>
      </label>
    `).join('')

    this.unitListTarget.innerHTML = `<div class="space-y-4">${html}</div>`
    console.log("✅ Units rendered successfully")
  }

  // 単元が選択されたとき
  async onUnitChange(event) {
    this.selectedUnitId = event.target.value
    const unitName = event.target.dataset.unitName
    console.log("📌 Unit selected:", this.selectedUnitId, unitName)

    // 全ての単元カードから selected クラスを削除
    const allUnitCards = document.querySelectorAll('.unit-card')
    allUnitCards.forEach(card => card.classList.remove('selected'))

    // 選択された単元カードに selected クラスを追加
    const selectedCard = event.target.closest('label').querySelector('.unit-card')
    if (selectedCard) {
      selectedCard.classList.add('selected')
    }

    if (this.hasSettingsSectionTarget) {
      this.settingsSectionTarget.classList.remove("hidden")
      
      // スムーズスクロール
      setTimeout(() => {
        this.settingsSectionTarget.scrollIntoView({ behavior: "smooth", block: "start" })
      }, 100)
    }
    if (this.hasSubmitSectionTarget) {
      this.submitSectionTarget.classList.remove("hidden")
    }

    await this.updateAvailableQuestions()
  }

  // 難易度が変更されたとき
  async onDifficultyChange(event) {
    console.log("📌 Difficulty changed:", event.target.value)
    await this.updateAvailableQuestions()
  }

  // 問題数が変更されたとき
  async onQuestionCountChange(event) {
    console.log("📌 Question count changed:", event.target.value)
    await this.updateAvailableQuestions()
  }

  // 利用可能な問題数を更新
  async updateAvailableQuestions() {
    if (!this.selectedUnitId) {
      console.log("⚠️ No unit selected, skipping update")
      return
    }

    const difficulty = this.difficultySelectTarget.value || ''
    console.log("🔄 Updating available questions:", { unitId: this.selectedUnitId, difficulty })

    try {
      const response = await fetch(
        `/test_sheets/available_questions?unit_id=${this.selectedUnitId}&difficulty=${difficulty}`
      )
      
      if (!response.ok) {
        throw new Error('Failed to fetch available questions')
      }

      const data = await response.json()
      console.log("✅ Available questions:", data)
      
      if (this.hasAvailableCountTarget) {
        this.availableCountTarget.textContent = data.available_count
      }
      
      const requestedCount = parseInt(this.questionCountSelectTarget.value)
      if (data.available_count < requestedCount) {
        console.warn("⚠️ Not enough questions available")
        if (this.hasAvailableInfoTarget) {
          this.availableInfoTarget.classList.add('text-red-600')
          this.availableInfoTarget.classList.remove('text-gray-600')
        }
        if (this.hasSubmitButtonTarget) {
          this.submitButtonTarget.disabled = true
          this.submitButtonTarget.classList.add('cursor-not-allowed', 'opacity-50')
        }
      } else {
        console.log("✅ Enough questions available")
        if (this.hasAvailableInfoTarget) {
          this.availableInfoTarget.classList.remove('text-red-600')
          this.availableInfoTarget.classList.add('text-gray-600')
        }
        if (this.hasSubmitButtonTarget) {
          this.submitButtonTarget.disabled = false
          this.submitButtonTarget.classList.remove('cursor-not-allowed', 'opacity-50')
        }
      }

    } catch (error) {
      console.error("❌ Failed to update available questions:", error)
    }
  }

  // フォーム送信時（連打防止）
  async handleSubmit(event) {
    if (this.isSubmitting) {
      event.preventDefault()
      console.log("⚠️ Already submitting, prevented double submission")
      return false
    }

    // 確認ダイアログ
    if (!confirm("テストを作成します。よろしいですか？")) {
      event.preventDefault()
      return false
    }

    this.isSubmitting = true
    this.showLoading()

    // 送信ボタンを無効化
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.textContent = "作成中..."
    }

    // 3秒後に再度有効化（エラー時のため）
    setTimeout(() => {
      this.isSubmitting = false
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.textContent = "テストを作成"
      }
      this.hideLoading()
    }, 3000)

    return true
  }

  // HTMLエスケープ
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
