class WorkDateException < ApplicationRecord
  belongs_to :employee
  has_many :paid_leave_transactions
  belongs_to :work_date_exception_request

  ALLOWED_COMBINATIONS = [
    Set[:holiday_work, :paid_leave],
    Set[:holiday_work, :hourly_paid_leave],
    Set[:special_leave, :holiday_work]
].freeze
  validate :validate_same_date_exception_combination
  validate :validate_exception_type_for_work_date

  enum :exception_type, {
    paid_leave: 10,
    hourly_paid_leave: 13,
    hospitalization: 11,
    special_leave: 12,
    holiday_work: 21
  }
  enum :usage_status, {
    pending: 0,
    used: 1,
    unused: 2
  }

  def validate_same_date_exception_combination
    exist_exceptions = self.employee.work_date_exceptions
      .where(work_date: self.work_date)
      .where.not(id: self.id)
      .pluck(:exception_type)

      return if exist_exceptions.empty?

      current_combination = Set.new(exist_exceptions + [ self.exception_type ])
      return if ALLOWED_COMBINATIONS.include?(current_combination)

      if current_combination.where { |num| num / 10 == 1 }.count >= 2
        error.add(:date, "にすでに休暇や時間単位有給休暇が設定されており、例外日を作成できません。")
      elsif current_combination.where { |num| num / 10 == 2 }.count >= 2
        error.add(:date, "にすでに休日出勤が設定されており、例外日を作成できません。")
      else
        error.add(:date, "不明な就業日例外エラーが発生しました。")
      end
  end

  def validate_exception_type_for_work_date
  end
end
