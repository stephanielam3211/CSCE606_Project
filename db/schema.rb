# frozen_string_literal: true
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

ActiveRecord::Schema[7.2].define(version: 2025_02_07_072030) do
  create_table "applicants", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "degree"
    t.string "positions"
    t.text "number"
    t.integer "uin"
    t.integer "hours"
    t.string "citizenship"
    t.integer "cert"
    t.text "prev_course"
    t.text "prev_uni"
    t.text "prev_ta"
    t.string "advisor"
    t.integer "choice_1"
    t.integer "choice_2"
    t.integer "choice_3"
    t.integer "choice_4"
    t.integer "choice_5"
    t.integer "choice_6"
    t.integer "choice_7"
    t.integer "choice_8"
    t.integer "choice_9"
    t.integer "choice_10"
    t.time "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
