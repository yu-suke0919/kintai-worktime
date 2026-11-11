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

ADMIN_NAME = "管理人"

LEADER_NAME = "リーダー"
LEADER_LABEL = [ 'A', 'B' ]

MEMBER_NAME = "メンバー"
MEMBER_HEADCOUNT_PER_LEADER = 3


employees = []
# 管理人生成
admin = Employee.create!(name: ADMIN_NAME, email: "admin@email", password: "000000", role: "admin")
employees.push(admin)
# マネージャー生成
LEADER_LABEL.each do |label|
  leader = Employee.create!(name: "#{LEADER_NAME}#{label}", email: "leader#{label}@email", password: "000000", role: "manager", manager_id: admin.id)
  employees.push(leader)
  leader.paid_leave_grants.create!(
    granted_by: admin,
    granted_days: 10,
    granted_minutes: 4800,
    granted_on: ATTENDANCE_START_DATE.advance(months: 6),
    expires_on: ATTENDANCE_START_DATE.advance(months: 30)
  )
  # 従業員生成
  (1..MEMBER_HEADCOUNT_PER_LEADER).each do |num|
    member = Employee.create!(name: "#{MEMBER_NAME}#{label}#{num}", email: "member#{label}#{num}@email", password: "000000", role: "member", manager_id: leader.id)
    employees.push(member)
    member.paid_leave_grants.create!(
      granted_by: leader,
      granted_days: 10,
      granted_minutes: 4800,
      granted_on: ATTENDANCE_START_DATE.advance(months: 6),
      expires_on: ATTENDANCE_START_DATE.advance(months: 30)
    )
  end
end

employees.each do |employee|
  employee.employee_rules.create!(
    required_workdays_mask: 62,
    core_time_start: "2000-01-01 09:00:00",
    core_time_end: "2000-01-01 18:00:00",
    break_minutes: 60,
    effective_from:  Date.new(2026, 4, 1),
    expires_on:  Date.new(2028, 3, 31)
  )

  (ATTENDANCE_START_DATE..ATTENDANCE_LATEST_DATE).each do |date|
    datetime = date.in_time_zone
    next if datetime.sunday?
    next if datetime.saturday?
    attendance = employee.attendances.create!(worked_on: date)

    case rand(1..100)
    when 1..94
      attendance.stamp_start(time: Time.zone.local(date.year, date.month, date.day, 8, rand(0..59)))
      attendance.stamp_break_start(time: Time.zone.local(date.year, date.month, date.day, 12, rand(0..5)))
      attendance.stamp_break_finish(time: Time.zone.local(date.year, date.month, date.day, 13, rand(55..59)))
      attendance.stamp_finish(time: Time.zone.local(date.year, date.month, date.day, 17, rand(0..59)))
    when 95..97
      attendance.stamp_start(time: Time.zone.local(date.year, date.month, date.day, 8, rand(0..59)))
      attendance.stamp_finish(time: Time.zone.local(date.year, date.month, date.day, 17, rand(0..59)))

      requested_started_at = attendance.original_started_at
      requested_finished_at = attendance.original_finished_at
      requested_break_started_at = Time.zone.local(date.year, date.month, date.day, 14, 0)
      requested_break_finished_at = Time.zone.local(date.year, date.month, date.day, 15, 0)
      attendance.create_attendance_edit_request!(employee:, requested_started_at:, requested_finished_at:, requested_break_started_at:, requested_break_finished_at:)

      if date >= ATTENDANCE_LATEST_DATE.prev_month.beginning_of_month
        attendance.attendance_edit_request.notifications.create(
          notification_type: :pending,
          recipient_employee: employee,
          message_text: "打刻時間修正の申請が完了しました。"
        )
      else
        attendance.update(
        started_at: attendance.attendance_edit_request.requested_started_at,
        finished_at: attendance.attendance_edit_request.requested_finished_at,
        break_started_at: attendance.attendance_edit_request.requested_break_started_at,
        break_finished_at: attendance.attendance_edit_request.requested_break_finished_at,
        status: "corrected"
      )
      end
    else
      attendance.stamp_start(time: Time.zone.local(date.year, date.month, date.day, 12, 0))
      attendance.stamp_break_start(time: Time.zone.local(date.year, date.month, date.day, 12, rand(1..5)))
      attendance.stamp_break_finish(time: Time.zone.local(date.year, date.month, date.day, 13, rand(55..59)))
      attendance.stamp_finish(time: Time.zone.local(date.year, date.month, date.day, 17, rand(0..59)))

      requested_started_at = Time.zone.local(date.year, date.month, date.day, 9, 0)
      requested_finished_at = attendance.original_finished_at
      requested_break_started_at = attendance.original_break_started_at
      requested_break_finished_at = attendance.original_break_finished_at
      attendance.create_attendance_edit_request!(employee:, requested_started_at:, requested_finished_at:, requested_break_started_at:, requested_break_finished_at:)
      if date >= ATTENDANCE_LATEST_DATE.prev_month.beginning_of_month
        attendance.attendance_edit_request.notifications.create(
          notification_type: :pending,
          recipient_employee: employee,
          message_text: "打刻時間修正の申請が完了しました。"
        )
      else
        attendance.update!(
        started_at: attendance.attendance_edit_request.requested_started_at,
        finished_at: attendance.attendance_edit_request.requested_finished_at,
        break_started_at: attendance.attendance_edit_request.requested_break_started_at,
        break_finished_at: attendance.attendance_edit_request.requested_break_finished_at,
        status: "corrected"
        )
      end
    end
  end
end

LEADER_LABEL.each do |label|
  (1..MEMBER_HEADCOUNT_PER_LEADER).each do |num|
    employee = Employee.find_by!(name: "#{MEMBER_NAME}#{label}#{num}")


    # 残タスク_リーダーに通知
    # 先月にworkschedulechandecaseの承諾済みのを入れる
    # たまにpaidleave以外の休暇を入れる、休日出勤を入れる
    # 先月までmonthlyAttendanceClosingを入れる
    # ここSEEDSにコメントを入れる
    request_type = :paid_leave
    start_date = (Date.current.next_day..).lazy.select { |d|d.on_weekday? }.first(rand(1..7)).last
    end_date = start_date.next_day.on_weekday? ? start_date.next_day : start_date
    reason = [ "誕生日だから", "発売日だから" ][rand(0..1)]

    change_case = employee.work_schedule_change_cases.build(request_type:, start_date:, end_date:, reason:)
    WorkScheduleChangeCases::ExceptionCreator.new(
      exception_request: change_case
    ).call
  end
end

# target_e = Employee.find_by(name: "従業員_A_1")
# target_a = target_e.attendances.find_by(worked_on: '2026-06-02')
# target_a.attendance_edit_request.create(epmloyee_id: target_e.id, approved_at: Time.current, approved_by_id: 1,)
