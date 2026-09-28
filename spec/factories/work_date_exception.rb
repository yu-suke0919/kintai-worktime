FactoryBot.define do
  factory :work_date_exception do
    employee
    work_date_exception_request
    usage_status { :pending }
    trait :paid_leave do
      exception_type { "paid_leave" }
      after(:build) do |exception|
        if exception.work_date.blank?
          raise ArgumentError, ":paid_leave を使う場合は work_date を指定してください"
        end
      end
    end
    trait :hourly_paid_leave do
      exception_type { "hourly_paid_leave" }
      starts_at { work_date_exception_request.starts_at }
      ends_at   { work_date_exception_request.ends_at }
      work_date { starts_at.to_date }
    end
  end
end
