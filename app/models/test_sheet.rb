# frozen_string_literal: true

class TestSheet < ApplicationRecord
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

  # ==================
  # enum 定義（Rails 7.1 形式）
  # ==================
  enum :difficulty, DIFFICULTIES, prefix: true # ← ここを修正

  # 以下は変更なし...
end
