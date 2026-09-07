class Admin::PaidLeaveBalancesController < ApplicationController
    before_action :authenticate_employee!
    before_action :set_employee
    before_action :admin_role_required
  def index
    @paid_leave_grant = @employee.paid_leave_grants.includes(:balances).find(params[:paid_leave_grant_id])
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  private
  def admin_role_required
    redirect_to employee_attendances_path(current_employee), alert: "権限がありません" if current_employee.role == "member"
  end
end
