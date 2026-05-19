class Admin::AttendanceEditRequestsController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  before_action :set_employee
  def index
    @has_request_attendances = @employee.has_request_attendances
  end

  def approve_edit_request
    attendance = Attendance.find(params[:id])
    raise if attendance.nil?
    request = attendance.attendance_edit_request

    attendance.update!(started_at: request.requested_started_at, finished_at: request.requested_finished_at, break_started_at: request.requested_break_started_at, break_finished_at: request.requested_break_finished_at)
    redirect_to admin_employees_path, notice: "勤怠時間の修正を行いました"
  end

  def show
  end

  def new
  end

  def edit
  end


    private

  def admin_role_required
    redirect_to employee_attendances_path(current_employee), alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
