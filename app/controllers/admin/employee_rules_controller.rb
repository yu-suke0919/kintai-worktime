class Admin::EmployeeRulesController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  before_action :set_employee
  def new
    new_params = latest_employee_rule_params
    if new_params.present?
      new_params.assign_attributes(effective_from: new_params[:expires_on]+(60*60*24))
      new_params.extract!(effective_from:)
    end
    @rule = EmployeeRule.new(new_params)
  end

  def create
    if @employee.employee_rules.create_association(employee_rule_params)
      redirect_to admin_employee_employee_rules_path(@employee.id), notice: "就業規則を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
  end

  private

  def employee_rule_params
    params.required(:employee_rule).permit(:break_minutes, :core_time_start, :core_time_end, :effective_from, :expires_on, :required_workdays_mask, :scheduled_work_minutes)
  end

  def latest_employee_rule_params
    latest_rule = @employee.employee_rules.last
    return {} if latest_rule.nil?
    latest_rule.attributes.symbolize_keys.except(:id) || {}
  end

  def admin_role_required
    redirect_to employee_attendances_path(current_employee), alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
