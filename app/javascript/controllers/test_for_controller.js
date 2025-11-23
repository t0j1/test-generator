import { Controller } from "@hotwired/stimulus"

// TestSheets#new フォームの動的制御
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
    console.log("TestFormController connected")
    this.units = {}
    this.selectedUnitId = null
  }

  // 科目が選択されたとき
  async onSubjectChange(event) {
    const subjectId = event.target.value
    console.log("Subject selected:", subjectId)

    this.unitSectionTarget.classList.remove("hidden")
    this.settingsSectionTarget.classList.add("hidden")
    this.submitSectionTarget.classList.add("hidden")

    await this.loadUnits(subjectId)
  }

  // 単元リストを取得
  async loadUnits(subjectId) {
    try {
      if (this.units[subjectId]) {
        this.renderUnits(this.units[subjectId])
        return
      }

      // 仮実装: APIから取得（後で実装）
      this.renderUnitsFromData(subjectId)
      
    } catch (error) {
      console.error("Failed to load units:", error)
      alert("単元の読み込みに失敗しました")
    }
  }

  // 仮実装: 単元データの表示
  renderUnitsFromData(subjectId) {
    const unitsHtml = `
      <div class="space-y-3">
        <p class="text-sm text-gray-500">科目ID: ${subjectId} の単元を選択してください</p>
      </div>
    `
    this.unitListTarget.innerHTML = unitsHtml
  }

  // 単元をレンダリング
  renderUnits(units) {
    const html = units.map(unit => `
      <label class="block cursor-pointer">
        <input 
          type="radio" 
          name="test_sheet[unit_id]" 
          value="${unit.id}" 
          class="peer hidden"
          data-action="change->test-form#onUnitChange"
          data-unit-name="${unit.name}"
          data-unit-grade="${unit.grade}"
          required
        >
        <div class="rounded-lg border-2 border-gray-200 p-4 transition-all hover:border-gray-400 peer-checked:border-4 peer-checked:border-blue-500 peer-checked:bg-blue-50">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-lg font-bold">${unit.name}</div>
              <div class="text-sm text-gray-500">高${unit.grade}</div>
            </div>
            <div class="text-sm text-gray-500">
              問題数: ${unit.question_count}問
            </div>
          </div>
        </div>
      </label>
    `).join('')

    this.unitListTarget.innerHTML = `<div class="space-y-3">${html}</div>`
  }

  // 単元が選択されたとき
  async onUnitChange(event) {
    this.selectedUnitId = event.target.value
    const unitName = event.target.dataset.unitName
    console.log("Unit selected:", this.selectedUnitId, unitName)

    this.settingsSectionTarget.classList.remove("hidden")
    this.submitSectionTarget.classList.remove("hidden")

    await this.updateAvailableQuestions()
  }

  // 難易度が変更されたとき
  async onDifficultyChange(event) {
    console.log("Difficulty changed:", event.target.value)
    await this.updateAvailableQuestions()
  }

  // 問題数が変更されたとき
  async onQuestionCountChange(event) {
    console.log("Question count changed:", event.target.value)
    await this.updateAvailableQuestions()
  }

  // 利用可能な問題数を更新
  async updateAvailableQuestions() {
    if (!this.selectedUnitId) {
      return
    }

    const difficulty = this.difficultySelectTarget.value || 'mix'

    try {
      const response = await fetch(
        `/test_sheets/available_questions?unit_id=${this.selectedUnitId}&difficulty=${difficulty}`
      )
      
      if (!response.ok) {
        throw new Error('Failed to fetch available questions')
      }

      const data = await response.json()
      
      this.availableCountTarget.textContent = data.available_count
      
      const requestedCount = parseInt(this.questionCountSelectTarget.value)
      if (data.available_count < requestedCount) {
        this.availableInfoTarget.classList.add('text-red-600')
        this.availableInfoTarget.classList.remove('text-gray-500')
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.classList.add('cursor-not-allowed', 'opacity-50')
      } else {
        this.availableInfoTarget.classList.remove('text-red-600')
        this.availableInfoTarget.classList.add('text-gray-500')
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove('cursor-not-allowed', 'opacity-50')
      }

    } catch (error) {
      console.error("Failed to update available questions:", error)
    }
  }
}
