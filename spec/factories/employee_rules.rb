FactoryBot.define do
  factory :employee_rule do
    employee { nil }
    required_workdays_mask { 1 }
    core_time_start { "2000-01-01 09:00:00" }
    core_time_end { "2000-01-01 17:00:00" }
    break_minutes { 1 }
    effective_from { "2026-06-01" }
    expires_on { "2026-06-30" }
  end
end
