class MonthlyAttendanceClosingsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee
  before_action :owner_or_admin_required
  def index
    permitted = params.permit(:select_year)
    match = permitted[:select_year]&.match(/\A(\d{4})-(0[0-9]|1[0-2])\z/)
    if match
      @year = Date.new(match[1].to_i, 1, 1)
    else
      @year = Date.current
      params[:select_month] = "#{@year.year}"
    end
    @monthly_attendance_closings = @employee.monthly_attendance_closings
  end

  def show
  end

  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def owner_or_admin_required
    redirect_to employee_attendances_path(current_employee), alert: "エラーが発生しました" if current_employee.id != params[:employee_id].to_i && current_employee.role == "member"
  end
end
