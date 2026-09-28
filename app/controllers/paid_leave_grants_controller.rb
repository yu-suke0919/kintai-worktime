class PaidLeaveGrantsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_grants
  before_action :set_employee
  def index
  end
  private
  def set_grants
    @paid_leave_grants = current_employee.paid_leave_grants.includes(:balances)
  end
  def set_employee
    @employee = current_employee
  end
end
