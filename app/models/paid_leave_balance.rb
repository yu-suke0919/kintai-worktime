class PaidLeaveBalance < ApplicationRecord
  belongs_to :paid_leave_grant
  belongs_to :employee_rule
  has_many :transactions, -> { order(effective_on: :asc, id: :asc) }, class_name: "PaidLeaveTransaction"
end
