class PaidLeaveGrant < ApplicationRecord
  belongs_to :employee
  belongs_to :granted_by_id
end
