class TestQuestion < ApplicationRecord
  # リレーション
  belongs_to :test_sheet
  belongs_to :question
  
  # バリデーション
  validates :question_order, presence: true, uniqueness: { scope: :test_sheet_id }
  
  # デフォルトスコープ（常に question_order で並び替え）
  default_scope { order(:question_order) }
end