FactoryBot.define do
  factory :paid_leave_grant do
    employee_id { nil }
    granted_by_id { nil }
    granted_minutes { 4800 }
    granted_on { "2026-04-01" }
    expires_on { "2028-03-31" }
  end
end
