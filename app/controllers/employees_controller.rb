class EmployeesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee, only: [ :show, :edit, :update ]
  def show
    @manager_name = @employee.manager_id ? Employee.find(@employee.manager_id).name : "未設定"
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
