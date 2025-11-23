# frozen_string_literal: true

class TestSheet < ApplicationRecord
  include Discard::Model
  # ==================
  # 定数定義
  # ==================

  # 難易度の定義（Question と同じ）
  DIFFICULTIES = {
    easy: 1,
    normal: 2,
    hard: 3
  }.freeze

  # 難易度のラベル（日本語・詳細版）
  DIFFICULTY_LABELS = {
    "easy" => "易しい(基礎)",
    "normal" => "普通(標準)",
    "hard" => "難しい(応用)"
  }.freeze

  # ミックス時のラベル
  MIX_LABEL = "ミックス(全難易度)"

  # 問題数の制約
  MIN_QUESTION_COUNT = 1
  MAX_QUESTION_COUNT = 100
  DEFAULT_QUESTION_COUNT = 10

  # デフォルト値
  DEFAULT_INCLUDE_HINT = false
  DEFAULT_INCLUDE_ANSWER = true

  # エラーメッセージ
  ERROR_INSUFFICIENT_QUESTIONS = "問が不足しています。利用可能: %<available>s問、要求: %<requested>s問"

  # ==================
  # リレーション
  # ==================
  belongs_to :subject
  belongs_to :unit
  has_many :test_questions, dependent: :destroy
  has_many :questions, through: :test_questions

  # Discard scope
  default_scope -> { kept }

  # ==================
  # enum 定義（Rails 7.1 形式）
  # ==================
  enum :difficulty, DIFFICULTIES, prefix: true

  # ==================
  # バリデーション
  # ==================
  validates :subject, presence: true
  validates :unit, presence: true
  validates :difficulty, presence: true
  validates :question_count, presence: true,
                             numericality: {
                               only_integer: true,
                               greater_than_or_equal_to: MIN_QUESTION_COUNT,
                               less_than_or_equal_to: MAX_QUESTION_COUNT
                             }

  # ==================
  # メソッド
  # ==================

  # 問題を生成してTestQuestionを作成する
  # @raise [StandardError] 問題数が不足している場合
  def generate_questions!
    # 利用可能な問題を取得
    available_questions = get_available_questions
    
    # 問題数チェック
    if available_questions.size < question_count
      raise StandardError, format(
        ERROR_INSUFFICIENT_QUESTIONS,
        available: available_questions.size,
        requested: question_count
      )
    end

    # ランダムに問題を選択（重複なし）
    selected_questions = available_questions.sample(question_count)

    # TestQuestionを作成
    transaction do
      selected_questions.each_with_index do |question, index|
        test_questions.create!(
          question: question,
          question_order: index + 1
        )
      end
    end
  end

  private

  # 利用可能な問題を取得
  # @return [ActiveRecord::Relation] 問題の配列
  def get_available_questions
    questions_scope = unit.questions.kept

    # 難易度フィルター
    if difficulty.present? && difficulty != "mix"
      questions_scope = questions_scope.where(difficulty: DIFFICULTIES[difficulty.to_sym])
    end

    questions_scope
  end
end
