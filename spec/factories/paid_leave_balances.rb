FactoryBot.define do
  factory :paid_leave_balance do
    association :employee_rule
    association :paid_leave_grant
    effective_from { Date.new(2026, 4, 1) }
  end
end
