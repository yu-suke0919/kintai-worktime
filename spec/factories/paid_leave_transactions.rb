FactoryBot.define do
  factory :paid_leave_transaction do
    paid_leave_grant { nil }
    delta_minutes { 1 }
    transaction_type { 1 }
    reason { "MyText" }
    effective_on { "2026-08-28" }
  end
end
