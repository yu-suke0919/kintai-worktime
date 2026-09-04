class PaidLeaveBalancesController < ApplicationController
    before_action :authenticate_employee!
    before_action :set_employee
  def index
    @grant = @employee.paid_leave_grants.includes(:balances).find(params[:paid_leave_grant_id])
  end

  def set_employee
    @employee = current_employee
  end
end
