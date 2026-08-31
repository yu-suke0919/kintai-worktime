class PaidLeaveGrantsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee
  def index
    @paid_leave_grants = @employee.paid_leave_grants
  end

  def set_employee
    @employee = current_employee
  end
end
