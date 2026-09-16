class PaidLeaveBalance < ApplicationRecord
  belongs_to :paid_leave_grant
  belongs_to :employee_rule

  validate :effective_from_cannot_be_changed, on: :update
  has_many :transactions, -> { order(effective_on: :asc, id: :asc) }, class_name: "PaidLeaveTransaction"

  private

  def effective_from_cannot_be_changed
    return unless will_save_change_to_attribute?(:effective_from)
    errors.add(:effective_from, "は変更不可")
  end
end
