FactoryBot.define do
  factory :employee_rule do
    employee { nil }
    required_workdays_mask { 1 }
    core_time_start { "2026-06-01 11:07:46" }
    core_time_end { "2026-06-01 11:07:46" }
    break_minutes { 1 }
    effective_from { "2026-06-01" }
    expires_on { "2026-06-01" }
  end
end
