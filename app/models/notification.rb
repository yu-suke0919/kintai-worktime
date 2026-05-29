class Notification < ApplicationRecord
  belongs_to :recipient_employee, class_name: "Employee", inverse_of: :notifications
  belongs_to :notifiable, polymorphic: true

  enum :notification_type, {
    pending: 0,
    approved: 1,
    rejected: 2
  }
end
