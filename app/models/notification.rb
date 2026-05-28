class Notification < ApplicationRecord
  belongs_to :recipient_employee, table_name: "Employee"
  belongs_to :notifiable, polymorphic: true
end
