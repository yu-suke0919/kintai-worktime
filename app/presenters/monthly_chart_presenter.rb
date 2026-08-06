class MonthlyChartPresenter
  def create(employee, date)
    target_dates = 1..date.end_of_month.day
    attendances_by_date = employee.attendances.where(worked_on: date.beginning_of_month..date.end_of_month).index_by { |attendance|attendance.worked_on.to_date.day }
    Rails.logger.debug attendances_by_date
    target_dates.map do |day|
      attendance = attendances_by_date[day]


      if attendance.present?
        workdate_zerohour = attendance.worked_on.in_time_zone.beginning_of_day
        {
          attendance_id: attendance.id,
          date: day,
          started_minutes: ((attendance.started_at - workdate_zerohour).to_i)/60,
          finished_minutes: ((attendance.finished_at - workdate_zerohour).to_i)/60,
          break_started_minutes: ((attendance.break_started_at - workdate_zerohour).to_i)/60,
          break_finished_minutes: ((attendance.break_finished_at - workdate_zerohour).to_i)/60
        }
      else
        {
          attendance_id: nil,
          date: day,
          started_minutes: nil,
          finished_minutes: nil,
          break_started_minutes: nil,
          break_finished_minutes: nil
        }
      end
    end
  end
end
