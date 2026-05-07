class AttendancesController < ApplicationController
  before_action :authenticate_employee!
  before_action :owner_or_admin_required
  before_action :set_attendance, only: [ :show, :update ]
  def index
    @attendances = Attendance.find_by(employee_id: params[:employee_id])
  end

  def show
  end
  def update
    column_name = params.require(:column_name)

    allowed_column = {
      "word_started_at" =>:started_at,
      "work_finished_at" => :finished_at,
      "break_started_at" =>:break_started_at,
      "break_finished_at" => :break_finished_at
    }
    target_column = allowed_column[column_name]
    raise ActionController::BadRequest if target_column.nil?

    @attendance.update!(target_column => Time.current)
  end

  private

  def set_attendance
    @attendance = Attendance.find_or_initialize_by(employee_id: params[:id], worked_on: params[:date])
  end

  def owner_or_admin_required
    redirect_to employee_attendances_path(current_employee) if current_employee.id != params[:employee_id].to_i && current_employee.role == "member"
  end

  def attendance_params
    params.require(:attendance).permit(:name, :description, :image)
  end
end
