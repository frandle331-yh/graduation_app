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

ActiveRecord::Schema[8.1].define(version: 2026_03_04_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "household_members", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.bigint "household_id", null: false
    t.datetime "joined_at"
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["household_id", "user_id"], name: "index_household_members_on_household_id_and_user_id", unique: true
    t.index ["household_id"], name: "index_household_members_on_household_id"
    t.index ["user_id"], name: "index_household_members_on_user_id"
  end

  create_table "households", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "invitation_code", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_households_on_created_by_id"
    t.index ["invitation_code"], name: "index_households_on_invitation_code", unique: true
  end

  create_table "housework_logs", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "household_id"
    t.text "memo"
    t.integer "minutes"
    t.date "performed_on", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["household_id", "performed_on"], name: "index_housework_logs_on_household_id_and_performed_on"
    t.index ["household_id"], name: "index_housework_logs_on_household_id"
    t.index ["user_id", "performed_on"], name: "index_housework_logs_on_user_id_and_performed_on"
    t.index ["user_id"], name: "index_housework_logs_on_user_id"
  end

  create_table "housework_templates", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "household_id"
    t.integer "minutes"
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["household_id"], name: "index_housework_templates_on_household_id"
    t.index ["user_id", "position"], name: "index_housework_templates_on_user_id_and_position"
    t.index ["user_id"], name: "index_housework_templates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "nickname"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "withdrawn_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["withdrawn_at"], name: "index_users_on_withdrawn_at"
  end

  add_foreign_key "household_members", "households"
  add_foreign_key "household_members", "users"
  add_foreign_key "households", "users", column: "created_by_id"
  add_foreign_key "housework_logs", "households"
  add_foreign_key "housework_logs", "users"
  add_foreign_key "housework_templates", "households"
  add_foreign_key "housework_templates", "users"
end
