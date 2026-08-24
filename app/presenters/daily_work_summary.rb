DailyWorkSummary = Data.define(
    :date,
    :is_work_scheduled,
    :attendance_status,
    :started_at,
    :finished_at,
    :break_started_at,
    :break_finished_at,
    :edit_request_present?,
    :work_date_exception,
  ) do
    extend ActiveModel::Translation
end
