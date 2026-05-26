class EmployeesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee, only: [ :show, :edit, :update ]
  def show
  end

  def edit
  end

  def update
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end
end
