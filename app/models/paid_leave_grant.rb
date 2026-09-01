class PaidLeaveGrant < ApplicationRecord
  attr_accessor :granted_days
  attr_accessor :granted_hours

  belongs_to :employee
  belongs_to :granted_by, class_name: "Employee", foreign_key: :granted_by_id
end
