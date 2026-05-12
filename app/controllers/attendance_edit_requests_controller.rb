class AttendanceEditRequestsController < ApplicationController
  before_action current_attendance only: [ :show, :new, :edit, :create, :update ]
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  private

  def current_attendance
    @attendance = Attendance.find_by(employee_id: params[:employee_id], worked_on: params[:worked_on])
  end
end
