class WorkDateException < ApplicationRecord
  belongs_to :employee
  has_many :paid_leave_transactions
  belongs_to :work_date_exception_request

  enum :exception_type, {
    paid_leave: 10,
    hospitalization: 11,
    special_leave: 12
  }
  enum :usage_status, {
    pending: 0,
    used: 1,
    unused: 2
  }
end
