# frozen_string_literal: true

class CreateSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :subjects do |t|
      t.string :name
      t.string :color_code
      t.integer :sort_order

      t.timestamps
    end
  end
end
