class AttendancesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee, except: :show_today
  before_action :owner_or_admin_required, except: :show_today
  before_action :set_attendance, only: [ :show, :update ]
  ALLOWED_COLUMN = {
    "started_at" => :started_at,
    "finished_at" => :finished_at,
    "break_started_at" => :break_started_at,
    "break_finished_at" => :break_finished_at
  }.freeze
  ORIGINAL_ALLOWED_COLUMN = {
    "started_at" => :original_started_at,
    "finished_at" => :original_finished_at,
    "break_started_at" => :original_break_started_at,
    "break_finished_at" => :original_break_finished_at
  }.freeze

  def index
    @attendances = @employee.attendances.order(worked_on: :desc).page(params[:page]).per(10)
  end

  def show
  end
  def update
    case params.require(:update_parameter_name)
    when "started_at" then
      result = @attendance.stamp_start
    when "finished_at" then
      result = @attendance.stamp_finish
    when "break_started_at" then
      result = @attendance.stamp_break_start
    when "break_finished_at" then
      result = @attendance.stamp_break_finish
    when "delete_recent_columns" then
      result = @attendance.cancel_stamp_within_5_minutes
    else
      raise ActionController::BadRequest
    end
    if result
      redirect_to employee_attendance_path(@employee, @attendance.worked_on)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def show_today
    redirect_to employee_attendance_path(current_employee.id, Date.today)
  end

  private
  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def set_attendance
    @attendance = Attendance.find_or_create_by(employee_id: params[:employee_id], worked_on: params[:worked_on])
  end

  def owner_or_admin_required
    redirect_to employee_attendances_path(current_employee), alert: "エラーが発生しましたb" if current_employee.id != params[:employee_id].to_i && current_employee.role == "member"
  end
end
