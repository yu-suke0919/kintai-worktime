class DailyWorkSummariesPresenter
  def initialize(employee, selected_month)
    @employee = employee
    @month = selected_month
  end
  def daily_work_summaries
    target_dates_in_month = @month.all_month
    target_attendances = @employee.attendances.includes(:attendance_edit_request).where(worked_on: target_dates_in_month).index_by(&:worked_on)
    target_work_date_exception = @employee.work_date_exceptions.where(work_date: target_dates_in_month).index_by(&:work_date)
    mask = @employee.employee_rules&.last&.required_workdays_mask || 0
    is_work_scheduled = target_dates_in_month.map { |date| [ date, ((2 ** (date.wday)) & mask == (2 ** (date.wday))) ? "出勤" : "休み" ] }.to_h

    target_dates_in_month.map do |date|
      DailyWorkSummary.new(
        date: date,
        is_work_scheduled: is_work_scheduled[date],
        attendance_status: target_attendances[date]&.status || "not_clocked",
        started_at: target_attendances[date]&.started_at,
        finished_at: target_attendances[date]&.finished_at,
        break_started_at: target_attendances[date]&.break_started_at,
        break_finished_at: target_attendances[date]&.break_finished_at,
        edit_request_present?: target_attendances[date]&.attendance_edit_request.present?,
        work_date_exception: target_work_date_exception[date]
      )
    end
  end
end
