FactoryBot.define do
  factory :employee_work_date_exception_request do
    employee { nil }
    approved_at { nil }
    approved_by_id { nil }
    status { 0 }
    request_type { 0 }
    start_date { "2026-06-03" }
    end_date { "2026-06-03" }
    reason { "MyText" }
  end
end
