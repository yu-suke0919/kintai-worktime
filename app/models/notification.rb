class Notification < ApplicationRecord
  belongs_to :recipient_employee, table_name: "Employee"
  belongs_to :notifiable, polymorphic: true

  enum :notification_type, {
    approved: 1,
    rejected: 2
  }
end
