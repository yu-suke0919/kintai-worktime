class PaidLeaveBalancesController < ApplicationController
    before_action :authenticate_employee!
    before_action :set_paid_leave_grants
    before_action :ensure_paid_leave_grant_owner!
  def index
    @balance_history = @paid_leave_grant.balance_history
  end

  def set_paid_leave_grants
    @paid_leave_grant = PaidLeaveGrant.find(params[:paid_leave_grant_id])
  end

  private
  def ensure_paid_leave_grant_owner!
    redirect_to employee_attendances_path(current_employee), alert: "この画面では他の従業員の有給休暇履歴を確認できません。" if @paid_leave_grant.employee_id != current_employee.id
  end
end
