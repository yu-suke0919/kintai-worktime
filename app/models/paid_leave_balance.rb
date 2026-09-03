class PaidLeaveBalance < ApplicationRecord
  belongs_to :paid_leave_grant
  belongs_to :previous_balances, class_name: "PaidLeaveBalance", optional: true

  enum :status, { active: 1, inactive: 2, scheduled: 3 }
end
