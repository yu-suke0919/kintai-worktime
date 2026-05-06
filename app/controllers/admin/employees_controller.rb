class Admin::EmployeesController < ApplicationController
  before_action :admin_role_required
  # before_action :set_manager
  def index
    @manager = current_employee
    @employees = Employee.order(
      Arel.sql(Employee.send(:sanitize_sql_array, [
        "CASE WHEN manager_id = ? THEN 0 ELSE 1 END, id ASC",
        current_employee.id
      ]))
    )
  end

  def show
  end

  def update
  end

  def edit
  end

  private

  def admin_role_required
    redirect_to employees_url, alert: "権限がありません" if current_employee.id < 1
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end
end
