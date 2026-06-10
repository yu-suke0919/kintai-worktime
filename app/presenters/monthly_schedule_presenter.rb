class MonthlySchedulePresenter
  Row = Struct.new(:date, :wday, :attendance_status, :started_at, :finished_at, :break_started_at, :break_finished_at, :is_work_scheduled, :edit_request_present?, :work_date_exception)

  def initialize(employee, month)
    @employee = employee
    @target_dates = month.beginning_of_month..month.end_of_month
  end

  def rows
    target_attendances = @employee.attendances.eager_load(:attendance_edit_request).where(worked_on: @target_dates).index_by(&:worked_on)
    target_work_date_exception = @employee.employee_work_date_exceptions.where(work_date: @target_dates).index_by(&:work_date)
    mask = @employee.employee_rules&.last&.required_workdays_mask || 0
    target_attendance_edit_requests = target_attendances.transform_values(&:attendance_edit_request)
    is_work_scheduled = @target_dates.map { |date| [ date, ((2 ** (date.wday)) & mask == (2 ** (date.wday))) ? "出勤" : "休み" ] }.to_h

    @target_dates.map do |date|
      Row.new(
        date: date,
        wday: [ "\u65E5", "\u6708", "\u706B", "\u6C34", "\u6728", "\u91D1", "\u571F" ][date.wday],
        attendance_status: target_attendances[date]&.status || "not_clocked",
        started_at: target_attendances[date]&.started_at,
        finished_at: target_attendances[date]&.finished_at,
        break_started_at: target_attendances[date]&.break_started_at,
        break_finished_at: target_attendances[date]&.break_finished_at,
        is_work_scheduled: is_work_scheduled[date],
        edit_request_present?: target_attendance_edit_requests[date].present?,
        work_date_exception: target_work_date_exception[date]
      )
    end
  end
end
