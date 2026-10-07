class WorkDateException < ApplicationRecord
  belongs_to :employee
  has_many :paid_leave_transactions
  belongs_to :work_date_exception_request

  ALLOWED_COMBINATIONS = [
    Set[:holiday_work, :paid_leave],
    Set[:holiday_work, :hourly_paid_leave],
    Set[:special_leave, :holiday_work]
].freeze
  validate :work_date_exceptions_must_be_consistent

  enum :exception_type, {
    paid_leave: 10,
    hospitalization: 11,
    special_leave: 12,
    hourly_paid_leave: 13,
    anniversary_holiday: 14,

    holiday_work: 20
  }
  enum :usage_status, {
    pending: 0,
    used: 1,
    unused: 2
  }

  def work_date_exceptions_must_be_consistent
    exist_exceptions = self.employee.work_date_exceptions
      .where(work_date: self.work_date)
      .where.not(id: self.id)
      .pluck(:exception_type)
    exist_exceptions << self.exception_type

    if exist_exceptions.size == 1

      if exist_exceptions[0] == :holiday_work
        if !self.employee.workday?(self.work_date)
          errors.add(:date, "は就業日ではないため、休暇を設定できません。")
        end
      else
        if self.employee.workday?(self.work_date)
          errors.add(:date, "は就業日であるため、休日出勤を設定できません。")
        end
      end
    elsif exist_exceptions.size > 1
      current_combination = Set.new(exist_exceptions)

      return if ALLOWED_COMBINATIONS.include?(current_combination)

      if current_combination.where { |num| num / 10 == 1 }.count >= 2
        errors.add(:date, "にすでに休暇や時間単位有給休暇が設定されており、例外日を作成できません。")
      elsif current_combination.where { |num| num / 10 == 2 }.count >= 2
        errors.add(:date, "にすでに休日出勤が設定されており、例外日を作成できません。")
      else
        errors.add(:date, "不明な就業日例外エラーが発生しました。")
      end
    end
  end
end
