class AttendanceEditRequestsController < ApplicationController
  before_action :set_attendance, only: [ :show, :new, :edit, :create, :update ]
  def index
  end

  def show
  end

  def new
    @edit_request = AttendanceEditRequest.new
  end

  def create
    @edit_request = @attendance.attendance_edit_requests.new(edit_request_params)
    @edit_request.employee_id = @employee.id
    if @edit_request.save
      redirect_to employee_attendances_path, notice: "勤怠修正申請を完了しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  private

  def set_attendance
    @employee = current_employee
    @attendance = @employee.attendances.find_by(worked_on: params[:attendance_worked_on])
  end

  def edit_request_params
    params.required(:attendance_edit_request).permit(:requested_started_at, :requested_finished_at, :requested_break_started_at, :requested_break_finished_at)
  end
end
