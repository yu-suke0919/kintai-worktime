class PaidLeaveTransaction < ApplicationRecord
  belongs_to :paid_leave_balance
  belongs_to :work_date_exception
end
