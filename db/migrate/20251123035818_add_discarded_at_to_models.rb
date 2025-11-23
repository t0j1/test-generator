class AddDiscardedAtToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :test_sheets, :discarded_at, :datetime
    add_index :test_sheets, :discarded_at
    
    add_column :test_questions, :discarded_at, :datetime
    add_index :test_questions, :discarded_at
  end
end
