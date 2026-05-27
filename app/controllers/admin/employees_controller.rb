class Admin::EmployeesController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  # before_action :set_manager
  before_action :set_employee, only: %i[update]
  def index
    @manager = current_employee
    @employees = Employee.order(
      Arel.sql(Employee.send(:sanitize_sql_array, [
        "CASE WHEN manager_id = ? THEN 0 ELSE 1 END, id ASC",
        current_employee.id
      ]))
    )
  end

  def subordinates
    @subordinates = current_employee.subordinates
  end

  def show
  end

  def update
    if @employee.update(manager_id: params[:manager_id])
        redirect_to admin_employees_path, notice: "社員情報を更新しました"
    else
        render :edit, status: :unprocessable_entity
    end
  end

  def edit
  end

  private

  def admin_role_required
    redirect_to employees_url, alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end
end
