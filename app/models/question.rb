# frozen_string_literal: true

# app/models/question.rb

class Question < ApplicationRecord
  include Discard::Model

  # ==================
  # 定数定義
  # ==================

  # 問題タイプの定義（string型カラム用）
  QUESTION_TYPES = {
    word: "word",
    sentence: "sentence",
    calculation: "calculation"
  }.freeze

  # 問題タイプのラベル（日本語）
  QUESTION_TYPE_LABELS = {
    "word" => "単語",
    "sentence" => "文章",
    "calculation" => "計算"
  }.freeze

  # 難易度の定義
  DIFFICULTIES = {
    easy: 1,
    normal: 2,
    hard: 3
  }.freeze

  # 難易度のラベル（日本語）
  DIFFICULTY_LABELS = {
    "easy" => "易しい",
    "normal" => "普通",
    "hard" => "難しい"
  }.freeze

  # デフォルト値
  DEFAULT_QUESTION_TYPE = :word
  DEFAULT_DIFFICULTY = :easy

  # ==================
  # リレーション
  # ==================
  belongs_to :unit
  has_many :test_questions, dependent: :destroy

  # Discard scope
  default_scope -> { kept }

  # ==================
  # enum 定義（Rails 7.1 形式）
  # ==================
  enum :question_type, QUESTION_TYPES              # ← ここを修正
  enum :difficulty, DIFFICULTIES, prefix: true     # ← ここを修正

  # ==================
  # バリデーション
  # ==================
  validates :question_text, presence: true
  validates :answer_text, presence: true
  
  # subject_idを委譲
  delegate :subject, to: :unit
  delegate :subject_id, to: :unit

  # CSVインポート
  def self.import_csv(file_path)
    require "csv"
    
    success_count = 0
    errors = []
    
    CSV.foreach(file_path, headers: true, encoding: "UTF-8") do |row|
      next if row.to_h.values.all?(&:blank?)
      
      question = new(
        unit_id: row["単元ID"] || row["unit_id"],
        question_type: row["問題タイプ"] || row["question_type"] || "word",
        difficulty: row["難易度"] || row["difficulty"] || "easy",
        question_text: row["問題文"] || row["question_text"],
        answer_text: row["解答"] || row["answer_text"],
        hint: row["ヒント"] || row["hint"],
        answer_note: row["解答ノート"] || row["answer_note"]
      )
      
      if question.save
        success_count += 1
      else
        errors << {
          row: row.to_h,
          line: $INPUT_LINE_NUMBER,
          errors: question.errors.full_messages
        }
      end
    end
    
    {
      success_count: success_count,
      error_count: errors.size,
      errors: errors
    }
  rescue StandardError => e
    {
      success_count: 0,
      error_count: 0,
      errors: [{ message: e.message }]
    }
  end
end
