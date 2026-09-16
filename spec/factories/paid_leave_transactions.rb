FactoryBot.define do
  factory :paid_leave_transaction do
    paid_leave_balance { nil }
    work_date_exception { nil }
    delta_days { 0 }
    delta_minutes { 0 }
    transaction_type { :use }
    reason { "CreatedByFactoryBot" }
    effective_on { Date.new(2026, 5, 1) }
  end
end
