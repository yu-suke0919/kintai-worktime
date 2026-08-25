class Admin::MonthlyAttendanceClosingApprovalsController < ApplicationController
  before_action :authenticate_employee!
  before_action :admin_role_required
  def index
    @pending_closing_approvals = MonthlyAttendanceClosingApproval.where(approver_id: current_employee.id).includes(:monthly_attendance_closing)
  end

  def approve_closing
    pending_closing_approval = MonthlyAttendanceClosingApproval.find(params[:id])
    pending_closing_approval.update(status: :approved)
    redirect_to admin_employee_monthly_attendance_closing_approvals_path, notice: "承認しました。"
  end
  def reject_closing
    pending_closing_approval = MonthlyAttendanceClosingApproval.find(params[:id])
    pending_closing_approval.update(status: :rejected)
    redirect_to admin_employee_monthly_attendance_closing_approvals_path, notice: "却下しました。"
  end

  private

  def admin_role_required
    redirect_to employee_attendances_path(current_employee), alert: "権限がありません" if current_employee.role == "member"
  end
end
