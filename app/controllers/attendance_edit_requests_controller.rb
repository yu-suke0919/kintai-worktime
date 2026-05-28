class AttendanceEditRequestsController < ApplicationController
  before_action :authenticate_employee!
  before_action :ensure_owner!
  before_action :set_attendance, only: [ :show, :new, :edit, :create, :update ]
  def index
    @has_request_attendances = current_employee.has_request_attendances
  end
  def show
  end

  def new
    @edit_request = AttendanceEditRequest.new
  end

  def create
    @edit_request = @attendance.build_attendance_edit_request(edit_request_params)
    @edit_request.employee_id = @employee.id
    if @edit_request.save
      @edit_request.notifications.create!(notification_type: 0, recipient_employee: current_employee, message_text: "message_text_desu")
      redirect_to employee_attendances_path, notice: "勤怠修正申請を完了しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @edit_request = @attendance.attendance_edit_request
  end

  def update
    if @attendance.attendance_edit_request.update(edit_request_params)
      @attendance.attendance_edit_request.notifications.create!(notification_type: 0, recipient_employee: current_employee, message_text: "message_text_desu")
      redirect_to employee_attendances_path, notice: "勤怠修正申請修正を完了しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_attendance
    @employee = current_employee
    @attendance = @employee.attendances.find_by(worked_on: params[:attendance_worked_on])
  end

  def ensure_owner!
    redirect_to employee_attendances_path(current_employee), alert: "自分以外の勤怠の修正はできません。" if params[:employee_id].to_i != current_employee.id
  end

  def edit_request_params
    params.required(:attendance_edit_request).permit(:requested_started_at, :requested_finished_at, :requested_break_started_at, :requested_break_finished_at)
  end
end
