# app/models/question.rb

class Question < ApplicationRecord
  # ==================
  # 定数定義
  # ==================
  
  # 問題タイプの定義
  QUESTION_TYPES = {
    word: 0,
    sentence: 1,
    calculation: 2
  }.freeze
  
  # 問題タイプのラベル（日本語）
  QUESTION_TYPE_LABELS = {
    'word'        => '単語',
    'sentence'    => '文章',
    'calculation' => '計算'
  }.freeze
  
  # 難易度の定義
  DIFFICULTIES = {
    easy: 1,
    normal: 2,
    hard: 3
  }.freeze
  
  # 難易度のラベル（日本語）
  DIFFICULTY_LABELS = {
    'easy'   => '易しい',
    'normal' => '普通',
    'hard'   => '難しい'
  }.freeze
  
  # デフォルト値
  DEFAULT_QUESTION_TYPE = :word
  DEFAULT_DIFFICULTY = :easy
  
  # ==================
  # リレーション
  # ==================
  belongs_to :unit
  has_many :test_questions, dependent: :destroy
  
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
  
  # 以下は変更なし...
end
