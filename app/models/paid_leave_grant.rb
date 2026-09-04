class PaidLeaveGrant < ApplicationRecord
  attr_accessor :granted_days
  attr_accessor :granted_hours
  after_create :synchronize_paid_leave_balances

  belongs_to :employee
  belongs_to :granted_by, class_name: "Employee", foreign_key: :granted_by_id
  has_many :balances, -> { order(effective_from: :asc, id: :asc) }, class_name: "PaidLeaveBalance"


  def synchronize_paid_leave_balances
    PaidLeaveBalances::Synchronizer.for_new_paid_leave_grant!(self)
  end
end
