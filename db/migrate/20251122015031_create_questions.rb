class CreateTestQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :test_questions do |t|
      t.references :test_sheet, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :question_order, null: false

      t.timestamps
    end
    
    # 複合ユニークインデックス
    add_index :test_questions, [:test_sheet_id, :question_order], unique: true
  end
end
