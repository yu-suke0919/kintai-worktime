class AddEmployeeRuleRefToPaidLeaveBalances < ActiveRecord::Migration[8.1]
  def change
    add_reference :paid_leave_balances, :employee_rule, null: false, foreign_key: true
  end
end
