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
    column_name = params.require(:update_parameter_name)

    if column_name == "delete_recent_columns"
      unless @attendance.working? || @attendance.normal?
        redirect_to employee_attendance_path(@employee, @attendance.worked_on)
        return
      end
      if @attendance.started_at.presence && @attendance.started_at >= 5.minutes.ago
        @attendance.started_at = nil
        @attendance.original_started_at = nil
      end
      if @attendance.finished_at.presence && @attendance.finished_at >= 5.minutes.ago
        @attendance.finished_at = nil
        @attendance.original_finished_at = nil
      end
      if @attendance.break_started_at.presence && @attendance.break_started_at >= 5.minutes.ago
        @attendance.break_started_at = nil
        @attendance.original_break_started_at = nil
      end
      if @attendance.break_finished_at.presence && @attendance.break_finished_at >= 5.minutes.ago
        @attendance.break_finished_at = nil
        @attendance.original_break_finished_at = nil
      end
      if @attendance.break_finished_at.nil?
        @attendance.status = "working"
      end
      if @attendance.started_at.nil?
        @attendance.status = "not_clocked"
      end
      @attendance.save!
    else
      target_column = ALLOWED_COLUMN[column_name]
      original_target_column = ORIGINAL_ALLOWED_COLUMN[column_name]

      raise ActionController::BadRequest if target_column.nil?
      raise ActionController::BadRequest if original_target_column.nil?

      if target_column == :started_at
        @attendance.status = "working"
      elsif target_column == :finished_at
        @attendance.status = "normal"
      end
      @attendance.update!(target_column => Time.current, original_target_column => Time.current)


    end

    redirect_to employee_attendance_path(@employee, @attendance.worked_on)
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
