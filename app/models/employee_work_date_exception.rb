class EmployeeWorkDateException < ApplicationRecord
  belongs_to :employee

    enum :exception_type, {
    paid_leave: 10,
    hospitalization: 11,
    special_leave: 12
  }
end
