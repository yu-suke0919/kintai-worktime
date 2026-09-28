class Admin::WorkDateExceptionRequestsController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  before_action :set_employee
  def index
    @exception_requests = @employee.work_date_exception_requests
  end

  def show
  end

  def approve_request
    WorkDateExceptionRequest.transaction do
      exception_request = @employee.work_date_exception_requests.lock.find(params[:id])
      exception_request.update!(status: 1, approved_at: Time.current, approved_by_id: current_employee.id)
      exception_request.work_date_exceptions.each do |exception|
        exception.update!(usage_status: :unused)
    end
      redirect_to admin_employee_work_date_exception_requests_path(@employee), notice: "承認に成功しました"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_employee_work_date_exception_requests_path(@employee), alert: "不明なエラー:employee_exception_request"
    end
  end

  def reject_request
    WorkDateExceptionRequest.transaction do
      exception_request = @employee.work_date_exception_requests.lock.find(params[:id])
      exception_request.update!(status: 2, approved_at: Time.current, approved_by_id: current_employee.id)
      exception_request.work_date_exceptions.each do |exception|
        exception.destroy!
      end
      redirect_to admin_employee_work_date_exception_requests_path(@employee), notice: "却下に成功しました"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_employee_work_date_exception_requests_path(@employee), alert: "不明なエラー:employee_exception_request"
    end
  end

  private

  def admin_role_required
    redirect_to employee_attendances_path(current_employee), alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
