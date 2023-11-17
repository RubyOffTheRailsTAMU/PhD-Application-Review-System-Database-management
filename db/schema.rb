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

ActiveRecord::Schema[7.1].define(version: 2023_11_12_203222) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applicants", force: :cascade do |t|
    t.string "application_cas_id"
    t.string "application_name"
    t.string "application_gender"
    t.string "application_citizenship_country"
    t.datetime "application_dob"
    t.string "application_email"
    t.string "application_degree"
    t.string "application_submitted"
    t.string "application_status"
    t.string "application_research"
    t.string "application_faculty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "application_ielts", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.integer "application_ielts_listening"
    t.integer "application_ielts_reading"
    t.integer "application_ielts_result"
    t.integer "application_ielts_speaking"
    t.integer "application_ielts_writing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_application_ielts_on_applicant_id"
  end

  create_table "datas", force: :cascade do |t|
    t.bigint "field_id", null: false
    t.string "cas_id", null: false
    t.string "subgroup"
    t.string "data_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subgroup_id"
    t.index ["field_id"], name: "index_datas_on_field_id"
    t.index ["subgroup_id"], name: "index_datas_on_subgroup_id"
  end

  create_table "fields", force: :cascade do |t|
    t.string "field_name", null: false
    t.string "field_alias", null: false
    t.boolean "field_used", null: false
    t.boolean "field_many", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gres", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.integer "application_gre_quantitative_scaled"
    t.integer "application_gre_quantitative_percentile"
    t.integer "application_gre_verbal_scaled"
    t.integer "application_gre_verbal_percentile"
    t.float "application_gre_analytical_scaled"
    t.integer "application_gre_analytical_percentile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_gres_on_applicant_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "review_id"
    t.string "user_netid"
    t.string "candidate_id"
    t.string "review_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schools", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.string "application_school_name"
    t.string "application_school_level"
    t.integer "application_school_quality_points"
    t.float "application_school_gpa"
    t.integer "application_school_credit_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_schools_on_applicant_id"
  end

  create_table "subgroups", force: :cascade do |t|
    t.string "subgroup_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "toefls", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.integer "application_toefl_listening"
    t.integer "application_toefl_reading"
    t.integer "application_toefl_result"
    t.integer "application_toefl_speaking"
    t.integer "application_toefl_writing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_toefls_on_applicant_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_netid", null: false
    t.string "user_name", null: false
    t.string "user_level", null: false
    t.string "user_email"
    t.string "password_digest"
  end

  add_foreign_key "application_ielts", "applicants", on_delete: :cascade
  add_foreign_key "datas", "fields", on_delete: :cascade
  add_foreign_key "datas", "subgroups", on_delete: :cascade
  add_foreign_key "gres", "applicants", on_delete: :cascade
  add_foreign_key "schools", "applicants", on_delete: :cascade
  add_foreign_key "toefls", "applicants", on_delete: :cascade
end
