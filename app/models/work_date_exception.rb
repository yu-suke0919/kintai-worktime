class WorkDateException < ApplicationRecord
  belongs_to :employee
  has_many :paid_leave_transactions

    enum :exception_type, {
    paid_leave: 10,
    hospitalization: 11,
    special_leave: 12
  }
end
