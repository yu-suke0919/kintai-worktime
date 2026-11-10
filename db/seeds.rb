# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
ATTENDANCE_START_DATE = Date.new(2026, 4, 1)
ATTENDANCE_LATEST_DATE = Date.yesterday

employees = []
# 管理人生成
admin = Employee.create!(name: "管理人", email: "admin@email", password: "000000", role: "admin")
employees.push(admin)
# マネージャー生成
[ 'A', 'B' ].each do |char|
  manager = Employee.create!(name: "リーダー#{char}", email: "leader#{char}@email", password: "000000", role: "manager", manager_id: 1)
  employees.push(manager)
  # 従業員生成
  (1..3).each do |num|
    member = Employee.create!(name: "メンバー#{char}#{num}", email: "member#{char}#{num}@email", password: "000000", role: "member", manager_id: manager.id)
    employees.push(member)
  end
end

employees.each do |employee|
  (ATTENDANCE_START_DATE..ATTENDANCE_LATEST_DATE).each do |date|
    datetime = date.in_time_zone
    next if datetime.sunday?
    next if datetime.saturday?
    attendance = employee.attendances.create!(worked_on: date)
    attendance.stamp_start(time: Time.zone.local(date.year, date.month, date.day, 8, rand(0..59)))
    attendance.stamp_break_start(time: Time.zone.local(date.year, date.month, date.day, 12, rand(0..5)))
    attendance.stamp_break_finish(time: Time.zone.local(date.year, date.month, date.day, 13, rand(55..59)))
    attendance.stamp_finish(time: Time.zone.local(date.year, date.month, date.day, 17, rand(0..59)))
  end
  employee.employee_rules.create!(
    required_workdays_mask: 62,
    core_time_start: "2000-01-01 09:00:00",
    core_time_end: "2000-01-01 18:00:00",
    break_minutes: 60,
    effective_from:  Date.new(2026, 4, 1),
    expires_on:  Date.new(2028, 3, 31)
  )
end

# target_e = Employee.find_by(name: "従業員_A_1")
# target_a = target_e.attendances.find_by(worked_on: '2026-06-02')
# target_a.attendance_edit_request.create(epmloyee_id: target_e.id, approved_at: Time.current, approved_by_id: 1,)
