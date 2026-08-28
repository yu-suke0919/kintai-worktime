FactoryBot.define do
  factory :paid_leave_grant do
    employee_id { nil }
    granted_by_id { nil }
    granted_minutes { 1 }
    granted_on { "2026-08-28" }
    expires_on { "2026-08-28" }
  end
end
