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
      (exception_request.start_date..exception_request.end_date).each do |date|
        @employee.employee_work_date_exceptions.create!(work_date: date, exception_type: exception_request.request_type.to_s)
      end
      redirect_to admin_employee_employee_work_date_exception_requests_path(@employee), notice: "承認に成功しました"
    else
      redirect_to admin_employee_employee_work_date_exception_requests_path(@employee), alert: "不明なエラー:employee_exception_request"
    end
  end

  def reject_request
    exception_request = @employee.employee_work_date_exception_requests.find(params[:id])
    if exception_request.update(status: 2, approved_at: Time.current, approved_by_id: current_employee.id)
      redirect_to admin_employee_employee_work_date_exception_requests_path(@employee), notice: "却下に成功しました"
    else
      redirect_to admin_employee_employee_work_date_exception_requests_path(@employee), alert: "不明なエラー:employee_exception_request"
    end
  end

  private

  def admin_role_required
    redirect_to employee_attendance_path(current_employee, worked_on: Date.today), alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
