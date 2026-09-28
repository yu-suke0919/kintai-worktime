class WorkDateExceptionRequest < ApplicationRecord
  belongs_to :employee
  has_many :work_date_exceptions, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :nullify
  validate :valid_time_range

  enum :request_type, {
    paid_leave: 10,
    hospitalization: 11,
    special_leave: 12,
    hourly_paid_leave: 13
  }
  enum :status, {
    pending: 0, approved: 1, rejected: 2
  }

  private
  def valid_time_range
    return if starts_at.blank? || ends_at.blank?
    if starts_at >= ends_at
      errors.add(:ends_at, "は開始日より後にしてください")
    elsif ends_at - starts_at > 24.hours
      errors.add(:ends_at, "は開始日から24時間以内を設定してください")
    end
  end


  def self.request_options
    request_types.map { |k, _| [ I18n.t("enums.work_date_exception_request.request_type.#{k}"), k ] }.to_h
  end

  def request_overview
    振替/休暇の修正申請です。
  end
end
