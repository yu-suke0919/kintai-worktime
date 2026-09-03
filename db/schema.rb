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

ActiveRecord::Schema[8.1].define(version: 2026_09_03_012823) do
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

  create_table "monthly_attendance_closing_approvals", force: :cascade do |t|
    t.integer "approval_order", null: false
    t.bigint "approver_id", null: false
    t.datetime "created_at", null: false
    t.bigint "monthly_attendance_closing_id", null: false
    t.text "reason"
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id", "status"], name: "idx_on_approver_id_status_34bde59c21"
    t.index ["approver_id"], name: "index_monthly_attendance_closing_approvals_on_approver_id"
    t.index ["monthly_attendance_closing_id", "approval_order"], name: "idx_on_monthly_attendance_closing_id_approval_order_837a8aaa9b", unique: true
    t.index ["monthly_attendance_closing_id"], name: "idx_on_monthly_attendance_closing_id_1e60e5654f"
  end

  create_table "monthly_attendance_closings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.date "target_month", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_monthly_attendance_closings_on_employee_id"
    t.index ["target_month", "employee_id"], name: "idx_on_target_month_employee_id_2a95ff0ef6", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message_text"
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.integer "notification_type", null: false
    t.datetime "read_at"
    t.bigint "recipient_employee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_employee_id"], name: "index_notifications_on_recipient_employee_id"
  end

  create_table "paid_leave_balances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "effective_from", null: false
    t.integer "minutes_per_day", null: false
    t.bigint "paid_leave_grant_id", null: false
    t.bigint "previous_balance_id"
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["paid_leave_grant_id"], name: "index_paid_leave_balances_on_paid_leave_grant_id"
    t.index ["previous_balance_id"], name: "index_paid_leave_balances_on_previous_balance_id"
  end

  create_table "paid_leave_grants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.date "expires_on", null: false
    t.bigint "granted_by_id"
    t.integer "granted_minutes", null: false
    t.date "granted_on", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_paid_leave_grants_on_employee_id"
    t.index ["granted_by_id"], name: "index_paid_leave_grants_on_granted_by_id"
  end

  create_table "paid_leave_transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "delta_minutes", null: false
    t.date "effective_on", null: false
    t.bigint "paid_leave_grant_id", null: false
    t.text "reason", null: false
    t.integer "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.index ["paid_leave_grant_id"], name: "index_paid_leave_transactions_on_paid_leave_grant_id"
  end

  create_table "work_date_exception_requests", force: :cascade do |t|
    t.datetime "approved_at"
    t.integer "approved_by_id"
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.date "end_date", null: false
    t.text "reason"
    t.integer "request_type", null: false
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_work_date_exception_requests_on_employee_id"
  end

  create_table "work_date_exceptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.integer "exception_type", null: false
    t.datetime "updated_at", null: false
    t.date "work_date", null: false
    t.index ["employee_id"], name: "index_work_date_exceptions_on_employee_id"
  end

  add_foreign_key "attendance_edit_requests", "attendances"
  add_foreign_key "attendance_edit_requests", "employees"
  add_foreign_key "attendances", "employees"
  add_foreign_key "employee_rules", "employees"
  add_foreign_key "employees", "employees", column: "manager_id"
  add_foreign_key "monthly_attendance_closing_approvals", "employees", column: "approver_id"
  add_foreign_key "monthly_attendance_closing_approvals", "monthly_attendance_closings"
  add_foreign_key "monthly_attendance_closings", "employees"
  add_foreign_key "notifications", "employees", column: "recipient_employee_id"
  add_foreign_key "paid_leave_balances", "paid_leave_balances", column: "previous_balance_id"
  add_foreign_key "paid_leave_balances", "paid_leave_grants"
  add_foreign_key "paid_leave_grants", "employees"
  add_foreign_key "paid_leave_grants", "employees", column: "granted_by_id"
  add_foreign_key "paid_leave_transactions", "paid_leave_grants"
  add_foreign_key "work_date_exception_requests", "employees"
  add_foreign_key "work_date_exceptions", "employees"
end
