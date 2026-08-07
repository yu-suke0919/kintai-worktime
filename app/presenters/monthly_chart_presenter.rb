class MonthlyChartPresenter
  def create(employee, date)
    target_dates = date.beginning_of_month..date.end_of_month
    attendances = employee.attendances.where(worked_on: date.beginning_of_month..date.end_of_month).index_by { |attendance|attendance.worked_on.to_date }
    result = target_dates.map do |date|
      attendance = attendances[date]


      if attendance&.started_at.present?
        workdate_zerohour = attendance.worked_on.in_time_zone.beginning_of_day
        {
          attendance_id: attendance.id,
          date: date,
          started_minutes: ((attendance.started_at - workdate_zerohour).to_i)/60,
          finished_minutes: ((attendance.finished_at - workdate_zerohour).to_i)/60,
          break_started_minutes: ((attendance.break_started_at - workdate_zerohour).to_i)/60,
          break_finished_minutes: ((attendance.break_finished_at - workdate_zerohour).to_i)/60
        }
      else
        {
          attendance_id: nil,
          date: date,
          started_minutes: nil,
          finished_minutes: nil,
          break_started_minutes: nil,
          break_finished_minutes: nil
        }
      end
    end

    if result.last[:finished_minutes]&. > 1440
      result.push(
        {
          attendance_id: nil,
          date: (date.end_of_month + 1.days),
          started_minutes: nil,
          finished_minutes: nil,
          break_started_minutes: nil,
          break_finished_minutes: nil
        }
      )
    end
    result
  end
end
