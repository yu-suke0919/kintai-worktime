class EmployeeInvitationsController < ApplicationController
  before_action :set_employee
  def edit
  end

  def update
  end

  def set_employee
    @employee = Employee.find_by_token_for(params[:employee_id])
  end
end
