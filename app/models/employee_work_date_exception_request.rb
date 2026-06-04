class EmployeeWorkDateExceptionRequest < ApplicationRecord
  belongs_to :employee

  has_many :notifications, as: :notifiable, dependent: :nullify

  enum :request_type, {
    paid_leave: 10,
    hospitalization: 11,
    special_leave: 12
  }

  def self.request_options
    request_types.map { |k, _| [ I18n.t("enums.employee_work_date_exception_request.request_type.#{k}"), k ] }.to_h
  end
end
