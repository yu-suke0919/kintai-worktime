class Employee < ApplicationRecord
  enum :role, { member: 0, manager: 1, admin: 2 }

  belongs_to :manager, class_name: "Employee", optional: true
  has_many :subordinates, class_name: "Employee", foreign_key: "manager_id", dependent: :nullify
  has_many :attendances, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_employee_id, dependent: :destroy, inverse_of: :recipient_employee
  has_many :employee_rules, dependent: :destroy
  has_many :employee_work_date_exception_requests, dependent: :destroy
  has_many :employee_work_date_exceptions, dependent: :destroy

  def has_request_attendances
    self.attendances.select { |a|a.attendance_edit_request.present? }
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
end
