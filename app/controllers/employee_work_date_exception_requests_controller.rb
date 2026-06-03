class EmployeeWorkDateExceptionRequestsController < ApplicationController
  def new
    @employee = current_employee
    @exception_request = EmployeeWorkDateExceptionRequest.new()
  end

  def edit
  end
end
