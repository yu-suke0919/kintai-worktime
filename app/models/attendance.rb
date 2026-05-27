class Attendance < ApplicationRecord
  enum :status, {
  not_clocked: 0,
  working: 1,
  normal: 2,
  abnormal: 3,
  absent: 4,
  paid_leave: 5,
  holiday: 6,
  corrected: 20
}

  belongs_to :employee
  has_one :attendance_edit_request, dependent: :destroy

  def stamp_start!(time: Time.current)
    raise ArgumentError, "すでに出勤済みです" if original_started_at.present?
    raise ArgumentError, "不正な打刻です" if status != "not_clocked"
    update!(started_at: time, original_started_at: time, status: "working")
  end

  def stamp_finish!(time: Time.current)
    raise ArgumentError, "すでに退勤済みです" if original_finished_at.present?
    raise ArgumentError, "不正な打刻です" if status != "working"
    update!(finished_at: time, original_finished_at: time, status: "normal")
  end

  def stamp_break_start!(time: Time.current)
    raise ArgumentError, "すでに打刻済みです" if original_break_started_at.present?
    raise ArgumentError, "不正な打刻です" if status != "working"
    update!(break_started_at: time, original_break_started_at: time)
  end

  def stamp_break_finish!(time: Time.current)
    raise ArgumentError, "すでに打刻済みです" if original_break_finished_at.present?
    raise ArgumentError, "不正な打刻です" if status != "working"
    update!(break_finished_at: time, original_break_finished_at: time)
  end
end
