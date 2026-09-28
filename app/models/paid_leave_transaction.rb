class PaidLeaveTransaction < ApplicationRecord
  belongs_to :paid_leave_balance
  belongs_to :work_date_exception

  enum :transaction_type, {
    use: 1
  }
end
