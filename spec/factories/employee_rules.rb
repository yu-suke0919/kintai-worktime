FactoryBot.define do
  factory :employee_rule do
    employee { nil }
    required_workdays_mask { 62 }
    core_time_start { "2000-01-01 09:00:00" }
    core_time_end { "2000-01-01 17:00:00" }
    break_minutes { 1 }
    effective_from { Date.new(2026, 4, 1) }
    expires_on { Date.new(2027, 3, 31) }
  end
end
