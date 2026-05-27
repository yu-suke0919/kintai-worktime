# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

employees = []
# 管理人生成
admin = Employee.create!(name: "管理人", email: "admin@email", password: "password", role: "admin")
employees.push(admin)
# マネージャー生成
[ 'A', 'B' ].each do |char|
  manager = Employee.create!(name: "マネージャー_#{char}", email: "manager#{char}@email", password: "password", role: "manager", manager_id: 1)
  employees.push(manager)
  # 従業員生成
  (1..3).each do |num|
    member = Employee.create!(name: "従業員_#{char}-#{num}", email: "member#{char}-#{num}@email", password: "password", role: "member", manager_id: manager.id)
    employees.push(member)
  end
end

employees.each do |employee|
  (1..31).each do |d|
    date = d.to_s.rjust(2, '0')
    attendance = employee.attendances.create!(worked_on: "2026-05-#{date}")
    attendance.stamp_start!(time: Time.zone.local(2026, 5, d, 8, rand(0..59)))
    attendance.stamp_break_start!(time: Time.zone.local(2026, 5, d, 12, 0))
    attendance.stamp_break_finish!(time: Time.zone.local(2026, 5, d, 13, 0))
    attendance.stamp_finish!(time: Time.zone.local(2026, 5, d, 17, rand(0..59)))
  end
end
