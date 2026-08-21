class MonthlyAttendanceClosingsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee
  before_action :owner_or_admin_required
  def index
    permitted = params.permit(:selected_year)
    match = permitted[:selected_year]&.match(/\A(\d{4})\z/)
    if match
      @selected_year = match[0].to_i
    else
      @selected_year = Date.today.year
    end
    range = Date.new(@selected_year, 1, 1).all_year
    @monthly_attendance_closings = @employee.monthly_attendance_closings.where(target_month: range).index_by { |closing|closing.target_month.month }
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
