class CreateUnits < ActiveRecord::Migration[8.1]
  def change
    create_table :units do |t|
      t.references :subject, null: false, foreign_key: true
      t.string :name
      t.integer :grade
      t.integer :sort_order

      t.timestamps
    end
  end
end
