class Notification < ApplicationRecord
  belongs_to :recipient_user
  belongs_to :notifiable, polymorphic: true
end
