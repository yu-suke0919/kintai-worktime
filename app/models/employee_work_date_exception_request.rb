class EmployeeWorkDateExceptionRequest < ApplicationRecord
  belongs_to :employee

  has_many :notifications, as: :notifiable, dependent: :nullify
end
