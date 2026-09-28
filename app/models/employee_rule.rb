class EmployeeRule < ApplicationRecord
  validates :effective_from, presence: true
  validates :expires_on, presence: true
  belongs_to :employee
  after_commit :synchronize_paid_leave_balances
  WEEKDAY_MASK ={
    sunday: 1,
    monday: 2,
    tuesday: 4,
    wednesday: 8,
    thursday: 16,
    friday: 32,
    saturday: 64
  }.freeze
  def in_office_days_hash
    hash = {}
    EmployeeRule::WEEKDAY_MASK.each do |day, mask|
      hash[day] = self.required_workdays_mask & mask == mask
    end
    hash
  end

  def in_office_days_text
    array = []
    EmployeeRule::WEEKDAY_MASK.each do |day, mask|
      array << EmployeeRule.human_attribute_name(day) if self.required_workdays_mask & mask == mask
    end
    array.join(",")
  end

  def in_office_days=(values)
    return if values.nil?
    self.required_workdays_mask = values
      .map { |key|EmployeeRule::WEEKDAY_MASK[key.to_sym] }
      .inject(:+)
  end

  def synchronize_paid_leave_balances
    PaidLeaveBalances::Synchronizer.for_new_employee_rule!(self)
  end
end
