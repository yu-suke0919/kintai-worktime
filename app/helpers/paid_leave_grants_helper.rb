module PaidLeaveGrantsHelper
  def balances_path_for(grant)
    if request.path_parameters[:employee_id].present?
      admin_employee_paid_leave_grant_paid_leave_balances_path(@employee, grant)
    else
      paid_leave_grant_paid_leave_balances_path(grant)
    end
  end
end
