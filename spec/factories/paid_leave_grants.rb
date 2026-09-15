FactoryBot.define do
  factory :paid_leave_grant do
    association :employee
    association :granted_by, factory: [ :employee, :manager ]
    granted_minutes { 4800 }
    granted_on { Date.new(2026, 4, 1) }
    expires_on { Date.new(2028, 3, 31) }
  end

  trait :expired_on_2026_03_31 do
    granted_on { Date.new(2024, 4, 1) }
    expires_on { Date.new(2026, 3, 31) }
  end
end
