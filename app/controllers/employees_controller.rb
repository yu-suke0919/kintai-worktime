class EmployeesController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_employee, only: [ :show, :edit, :update, :destroy ]
  def index
    @employee = current_employee
  end

  def show
  end

  def new
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end
end
