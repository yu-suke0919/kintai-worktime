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
end
