class Admin::AttendanceEditRequestsController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  before_action :set_employee
  def index
    @has_request_attendances = @employee.has_request_attendances
  end

  def show
  end

  def new
  end

  def edit
  end


    private

  def admin_role_required
    redirect_to employees_url, alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
