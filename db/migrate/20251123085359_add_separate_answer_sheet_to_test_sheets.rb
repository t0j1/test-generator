class AddSeparateAnswerSheetToTestSheets < ActiveRecord::Migration[8.1]
  def change
    add_column :test_sheets, :separate_answer_sheet, :boolean, default: true, null: false
  end
end
