class Admin::PaidLeaveGrantsController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  before_action :set_employee

  def index
    @paid_leave_grants = @employee.paid_leave_grants
  end

  def new
    @paid_leave_grant = PaidLeaveGrant.new()
  end
  def create
    @paid_leave_grant = @employee.paid_leave_grants.build(paid_leave_grant_params)
    @paid_leave_grant.granted_by = current_employee
    if @paid_leave_grant.save
      redirect_to admin_employee_paid_leave_grants_path(@employee.id), notice: "就業規則を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end



  private
  def paid_leave_grant_params
    params.required(:paid_leave_grant).permit(:granted_on, :granted_minutes, :expires_on)
  end

  def admin_role_required
    redirect_to employee_attendances_path(current_employee), alert: "権限がありません" if current_employee.role == "member"
  end

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end
end
