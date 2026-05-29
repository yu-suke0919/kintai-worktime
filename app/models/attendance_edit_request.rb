class AttendanceEditRequest < ApplicationRecord
  belongs_to :attendance
  belongs_to :employee

  has_many :notifications, as: :notifiable, dependent: :nullify

  def request_overview
    打刻時間の修正申請です。
  end
end
