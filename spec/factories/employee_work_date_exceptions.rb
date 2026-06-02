FactoryBot.define do
  factory :employee_work_date_exception do
    employee { nil }
    work_date { "2026-06-02" }
    exception_type { 1 }
  end
end
