class Unit < ApplicationRecord
  # ==================
  # 定数定義
  # ==================
  
  # 学年の範囲
  MIN_GRADE = 1
  MAX_GRADE = 3
  VALID_GRADES = (MIN_GRADE..MAX_GRADE).freeze
  
  # 難易度の定義（Question と同じ）
  DIFFICULTY_KEYS = %i[easy normal hard].freeze
  
  # ==================
  # リレーション
  # ==================
  belongs_to :subject
  has_many :questions, dependent: :destroy
  has_many :test_sheets, dependent: :destroy
  
  # ==================
  # バリデーション
  # ==================
  validates :name, presence: true
  validates :grade, inclusion: { in: VALID_GRADES }
  
  # ==================
  # スコープ
  # ==================
  scope :for_grade, ->(grade) { where(grade: grade) }
  scope :ordered, -> { order(:sort_order, :id) }
  
  # ==================
  # クラスメソッド
  # ==================
  
  # 学年の選択肢を取得（フォーム用）
  def self.grade_options_for_select
    VALID_GRADES.map do |grade|
      ["高#{grade}", grade]
    end
  end
  
  # ==================
  # インスタンスメソッド
  # ==================
  
  # 問題数取得（難易度指定可能）
  def question_count(difficulty: nil)
    scope = questions
    scope = apply_difficulty_scope(scope, difficulty) if difficulty
    scope.count
  end
  
  # 難易度別の問題数を一括取得
  def question_counts_by_difficulty
    DIFFICULTY_KEYS.each_with_object({ total: questions.count }) do |diff, hash|
      hash[diff] = questions.public_send("difficulty_#{diff}").count
    end
  end
  
  # 学年ラベル（日本語）
  def grade_label
    "高#{grade}"
  end
  
  private
  
  # 難易度スコープを適用
  def apply_difficulty_scope(scope, difficulty)
    scope.public_send("difficulty_#{difficulty}")
  end
end
