class Admin::EmployeeWorkDateExceptionRequestsController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  before_action :set_employee
  def index
    @exception_requests = @employee.employee_work_date_exception_requests
  end

  def show
  end

  def approve_request
    exception_request = @employee.employee_work_date_exception_requests.find(params[:id])
    if exception_request.update(status: 1, approved_at: Time.current, approved_by_id: current_employee.id)
      redirect_to admin_employee_employee_work_date_exception_requests_path(@employee)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def reject_request
  end

  private

  def admin_role_required
    redirect_to employee_attendance_path(current_employee, worked_on: Date.today), alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
