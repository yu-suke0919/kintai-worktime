class Employee < ApplicationRecord
  enum :role, { member: 0, manager: 1, admin: 2 }

  belongs_to :manager, class_name: "Employee", optional: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :subordinates, class_name: "Employee", foreign_key: "manager_id", dependent: :nullify
  has_many :attendances, dependent: :destroy
  has_many :attendance_edit_request
  has_many :notifications, foreign_key: :recipient_employee_id, dependent: :destroy, inverse_of: :recipient_employee
  has_many :employee_rules, dependent: :destroy
  has_many :work_date_exception_requests, dependent: :destroy
  has_many :work_date_exceptions, dependent: :destroy
  has_many :monthly_attendance_closings, dependent: :destroy
  has_many :paid_leave_grants, dependent: :destroy
  has_many :granted_paid_leave_grants, class_name: "PaidLeaveGrant", foreign_key: "granted_by_id"

  def has_request_attendances
    self.attendances.select { |a|a.attendance_edit_request.present? }
  end

  def current_total_paid_leave_balance
    current_remaining_leaves = { days: 0, hours: 0 }
    self.paid_leave_grants
      .where(granted_on: ..Date.today)
      .where(expires_on: Date.today..).each do |grant|
        remaining_leaves = grant.remaining_leaves
        current_remaining_leaves[:days] += remaining_leaves[:days]
        current_remaining_leaves[:hours] += remaining_leaves[:hours]
      end
    current_remaining_leaves
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable,:registerable,
  devise :database_authenticatable,
        :recoverable, :rememberable, :validatable

  generates_token_for :invitational, expires_in: 15.minutes do
    authenticatable_salt&.last(10)
  end
end
