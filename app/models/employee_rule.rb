class EmployeeRule < ApplicationRecord
  belongs_to :employee
  WEEKDAY_MASK ={
    sunday: 1,
    monday: 2,
    tuesday: 4,
    wednesday: 8,
    thursday: 16,
    friday: 32,
    saturday: 64
  }.freeze
  def in_office_days
    days = []
    EmployeeRule::WEEKDAY_MASK.each do |day, mask|
      days.push(day) if self.required_workdays_mask & mask == mask
    end
    days
  end

  def in_office_days=(value)
    self.required_workdays_mask = value
      .map { |key|EmployeeRule::WEEKDAY_MASK[key] }
      .inject(:+)
  end
end
