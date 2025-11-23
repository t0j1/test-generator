# frozen_string_literal: true

class Subject < ApplicationRecord
  # ==================
  # 定数定義
  # ==================

  # デフォルトの色
  DEFAULT_COLORS = {
    "英語" => "#EF4444",
    "数学" => "#3B82F6",
    "国語" => "#10B981",
    "理科" => "#8B5CF6",
    "社会" => "#F59E0B"
  }.freeze

  # ==================
  # リレーション
  # ==================
  has_many :units, dependent: :destroy
  has_many :test_sheets, dependent: :destroy

  # ==================
  # バリデーション
  # ==================
  validates :name, presence: true, uniqueness: true

  # ==================
  # スコープ
  # ==================
  scope :ordered, -> { order(:sort_order, :id) }

  # ==================
  # コールバック
  # ==================
  before_validation :set_default_color, on: :create

  # ==================
  # クラスメソッド
  # ==================

  # デフォルト色を取得
  def self.default_color_for(subject_name)
    DEFAULT_COLORS[subject_name] || "#6B7280"
  end

  private

  # デフォルト色を設定
  def set_default_color
    self.color_code ||= self.class.default_color_for(name)
  end
end
