# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_22_015051) do
  create_table "questions", force: :cascade do |t|
    t.text "answer_text"
    t.datetime "created_at", null: false
    t.integer "difficulty"
    t.text "hint"
    t.text "question_text"
    t.string "question_type"
    t.integer "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_questions_on_unit_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "color_code"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "sort_order"
    t.datetime "updated_at", null: false
  end

  create_table "test_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "question_id", null: false
    t.integer "question_order"
    t.integer "test_sheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_test_questions_on_question_id"
    t.index ["test_sheet_id"], name: "index_test_questions_on_test_sheet_id"
  end

  create_table "test_sheets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "difficulty"
    t.boolean "include_answer"
    t.boolean "include_hint"
    t.datetime "printed_at"
    t.integer "question_count"
    t.integer "subject_id", null: false
    t.integer "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_test_sheets_on_subject_id"
    t.index ["unit_id"], name: "index_test_sheets_on_unit_id"
  end

  create_table "units", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "grade"
    t.string "name"
    t.integer "sort_order"
    t.integer "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_units_on_subject_id"
  end

  add_foreign_key "questions", "units"
  add_foreign_key "test_questions", "questions"
  add_foreign_key "test_questions", "test_sheets"
  add_foreign_key "test_sheets", "subjects"
  add_foreign_key "test_sheets", "units"
  add_foreign_key "units", "subjects"
end
