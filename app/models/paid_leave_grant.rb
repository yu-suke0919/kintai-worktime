class PaidLeaveGrant < ApplicationRecord
  belongs_to :employee_id
  belongs_to :granted_by_id
end
