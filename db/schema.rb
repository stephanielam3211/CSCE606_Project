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

ActiveRecord::Schema[7.2].define(version: 2025_04_07_215454) do
  create_table "admins", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

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
    t.float "gpa"
    t.integer "confirm", default: 0, null: false
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "applicant_id", null: false
    t.string "course_id"
    t.integer "weighting_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_assignments_on_applicant_id"
  end

  create_table "blacklists", force: :cascade do |t|
    t.string "student_name"
    t.string "student_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string "course_name"
    t.string "course_number"
    t.string "section"
    t.string "instructor"
    t.string "faculty_email"
    t.float "ta"
    t.float "senior_grader"
    t.float "grader"
    t.text "pre_reqs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grader_matches", force: :cascade do |t|
    t.string "course_number"
    t.string "section"
    t.string "ins_name"
    t.string "ins_email"
    t.string "stu_name"
    t.string "stu_email"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uin"
    t.boolean "assigned"
    t.boolean "confirm"
    t.index ["uin"], name: "index_grader_matches_on_uin", unique: true
  end

  create_table "recommendations", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "selectionsTA"
    t.text "feedback"
    t.text "additionalfeedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course"
    t.boolean "admin"
  end

  create_table "senior_grader_matches", force: :cascade do |t|
    t.string "course_number"
    t.string "section"
    t.string "ins_name"
    t.string "ins_email"
    t.string "stu_name"
    t.string "stu_email"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uin"
    t.boolean "assigned"
    t.boolean "confirm"
    t.index ["uin"], name: "index_senior_grader_matches_on_uin", unique: true
  end

  create_table "ta_matches", force: :cascade do |t|
    t.string "course_number"
    t.string "section"
    t.string "ins_name"
    t.string "ins_email"
    t.string "stu_name"
    t.string "stu_email"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uin"
    t.boolean "assigned"
    t.boolean "confirm"
    t.index ["uin"], name: "index_ta_matches_on_uin", unique: true
  end

  create_table "unassigned_applicants", force: :cascade do |t|
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
    t.float "gpa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "withdrawal_requests", force: :cascade do |t|
    t.string "course_number"
    t.string "section_id"
    t.string "instructor_name"
    t.string "instructor_email"
    t.string "student_name"
    t.string "student_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "assignments", "applicants"
end
