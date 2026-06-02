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

ActiveRecord::Schema[8.1].define(version: 2026_06_01_034430) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendance_edit_requests", force: :cascade do |t|
    t.datetime "approved_at"
    t.integer "approved_by_id"
    t.bigint "attendance_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.text "reason"
    t.datetime "requested_break_finished_at"
    t.datetime "requested_break_started_at"
    t.datetime "requested_finished_at"
    t.datetime "requested_started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_attendance_edit_requests_on_attendance_id"
    t.index ["employee_id"], name: "index_attendance_edit_requests_on_employee_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.datetime "break_finished_at"
    t.datetime "break_started_at"
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.datetime "finished_at"
    t.datetime "original_break_finished_at"
    t.datetime "original_break_started_at"
    t.datetime "original_finished_at"
    t.datetime "original_started_at"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.date "worked_on", null: false
    t.index ["employee_id", "worked_on"], name: "index_attendances_on_employee_id_and_worked_on", unique: true
    t.index ["employee_id"], name: "index_attendances_on_employee_id"
  end

  create_table "employee_rules", force: :cascade do |t|
    t.integer "break_minutes", default: 0, null: false
    t.time "core_time_end"
    t.time "core_time_start"
    t.datetime "created_at", null: false
    t.date "effective_from", null: false
    t.bigint "employee_id", null: false
    t.date "expires_on", null: false
    t.integer "required_workdays_mask", default: 0, null: false
    t.integer "scheduled_work_minutes", default: 480, null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_rules_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.bigint "manager_id"
    t.string "name", null: false
    t.integer "paid_leave_balance", default: 0, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["manager_id"], name: "index_employees_on_manager_id"
    t.index ["reset_password_token"], name: "index_employees_on_reset_password_token", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message_text"
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.integer "notification_type"
    t.datetime "read_at"
    t.bigint "recipient_employee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_employee_id"], name: "index_notifications_on_recipient_employee_id"
  end

  add_foreign_key "attendance_edit_requests", "attendances"
  add_foreign_key "attendance_edit_requests", "employees"
  add_foreign_key "attendances", "employees"
  add_foreign_key "employee_rules", "employees"
  add_foreign_key "employees", "employees", column: "manager_id"
  add_foreign_key "notifications", "employees", column: "recipient_employee_id"
end
