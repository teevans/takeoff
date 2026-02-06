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

ActiveRecord::Schema[8.1].define(version: 2026_02_06_160341) do
  create_table "authentication_tokens", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.integer "user_id", null: false
    t.index ["code"], name: "index_authentication_tokens_on_code"
    t.index ["token"], name: "index_authentication_tokens_on_token", unique: true
    t.index ["user_id", "expires_at"], name: "index_authentication_tokens_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_invitations", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.integer "invited_by_id", null: false
    t.string "role", default: "member", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_invitations_on_company_id"
    t.index ["email"], name: "index_company_invitations_on_email"
    t.index ["invited_by_id"], name: "index_company_invitations_on_invited_by_id"
    t.index ["token"], name: "index_company_invitations_on_token", unique: true
  end

  create_table "company_users", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["company_id", "user_id"], name: "index_company_users_on_company_id_and_user_id", unique: true
    t.index ["company_id"], name: "index_company_users_on_company_id"
    t.index ["user_id"], name: "index_company_users_on_user_id"
  end

  create_table "notification_batches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_subscriptions", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.boolean "email_enabled", default: true, null: false
    t.integer "notification_type_id", null: false
    t.boolean "push_enabled", default: false, null: false
    t.boolean "sms_enabled", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["company_id"], name: "index_notification_subscriptions_on_company_id"
    t.index ["notification_type_id"], name: "index_notification_subscriptions_on_notification_type_id"
    t.index ["user_id", "company_id", "notification_type_id"], name: "index_notification_subs_on_user_company_type", unique: true
    t.index ["user_id"], name: "index_notification_subscriptions_on_user_id"
  end

  create_table "notification_types", force: :cascade do |t|
    t.string "category", null: false
    t.json "channels", default: ["email"]
    t.datetime "created_at", null: false
    t.boolean "default_enabled", default: true, null: false
    t.text "description"
    t.boolean "force_enabled", default: false, null: false
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_notification_types_on_category"
    t.index ["key"], name: "index_notification_types_on_key", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "address"
    t.decimal "budget", precision: 12, scale: 2
    t.string "city"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "estimated_completion_date"
    t.string "name", null: false
    t.string "project_type", null: false
    t.date "start_date"
    t.string "state"
    t.string "status", default: "planning", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["company_id", "status"], name: "index_projects_on_company_id_and_status"
    t.index ["company_id"], name: "index_projects_on_company_id"
    t.index ["project_type"], name: "index_projects_on_project_type"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_notification_settings", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "email_batch_minutes", default: 15, null: false
    t.time "quiet_hours_end", default: "2000-01-01 07:00:00", null: false
    t.time "quiet_hours_start", default: "2000-01-01 19:00:00", null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["company_id"], name: "index_user_notification_settings_on_company_id"
    t.index ["user_id", "company_id"], name: "index_user_notification_settings_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_user_notification_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest"
    t.string "phone_number"
    t.datetime "phone_verified_at"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number"
  end

  add_foreign_key "authentication_tokens", "users"
  add_foreign_key "company_invitations", "companies"
  add_foreign_key "company_invitations", "users", column: "invited_by_id"
  add_foreign_key "company_users", "companies"
  add_foreign_key "company_users", "users"
  add_foreign_key "notification_subscriptions", "companies"
  add_foreign_key "notification_subscriptions", "notification_types"
  add_foreign_key "notification_subscriptions", "users"
  add_foreign_key "projects", "companies"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_notification_settings", "companies"
  add_foreign_key "user_notification_settings", "users"
end
