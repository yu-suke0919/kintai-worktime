class PaidLeaveGrant < ApplicationRecord
  attr_accessor :granted_days, :granted_hours
  before_validation :set_granted_minutes
  after_create :synchronize_paid_leave_balances

  belongs_to :employee
  belongs_to :granted_by, class_name: "Employee", foreign_key: :granted_by_id
  has_many :balances, -> { order(effective_from: :asc, id: :asc) }, class_name: "PaidLeaveBalance"


  def synchronize_paid_leave_balances
    PaidLeaveBalances::Synchronizer.for_new_paid_leave_grant!(self)
  end
  def remaining_leaves
    PaidLeaves::BalanceCalculator.new(grant: self).remaining_leaves
  end

  def balance_history
    PaidLeaves::BalanceCalculator.new(grant: self).balance_history
  end

  private
  def set_granted_minutes
    self.granted_minutes = (granted_days.to_i * 480) + (granted_hours.to_i * 60)
  end
end
