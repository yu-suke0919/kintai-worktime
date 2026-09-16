FactoryBot.define do
  factory :work_date_exception do
    employee { nil }
    work_date_exception_request { nil }
    exception_type { nil }
    usage_status { :pending }
    work_date { Date.new(2026, 05, 01) }
    starts_at { DateTime.new(2026, 05, 01, 9, 0, 0) }
    ends_at { DateTime.new(2026, 05, 01, 12, 0, 0) }
  end
end
