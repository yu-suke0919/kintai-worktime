FactoryBot.define do
  factory :employee_work_date_exception_request do
    employee { nil }
    approved_at { "2026-06-03 14:41:35" }
    approved_by_id { 1 }
    status { 0 }
    request_type { 0 }
    start_date { "2026-06-03" }
    end_date { "2026-06-03" }
    reason { "MyText" }
  end
end
