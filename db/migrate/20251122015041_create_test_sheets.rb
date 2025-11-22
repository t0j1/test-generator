class CreateTestSheets < ActiveRecord::Migration[7.1]
  def change
    create_table :test_sheets do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true
      
      t.integer :question_count, default: 10, null: false
      
      # difficulty は NULL 許可（ミックスの場合は NULL）
      t.integer :difficulty
      
      t.boolean :include_hint, default: false, null: false
      t.boolean :include_answer, default: true, null: false
      t.datetime :printed_at

      t.timestamps
    end
    
    # インデックス追加
    add_index :test_sheets, :difficulty
    add_index :test_sheets, :printed_at
    add_index :test_sheets, :created_at
  end
end
