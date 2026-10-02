FactoryBot.define do
  factory :attendance_edit_request do
    attendance { nil }
    employee { nil }
    approved_by_id { 1 }
    approved_at { "2026-05-11 13:40:43" }
    status { 1 }
    requested_started_at { DateTime.new(2026, 5, 1, 8, 50, 00) }
    requested_finished_at { DateTime.new(2026, 5, 1, 18, 10, 00) }
    requested_break_started_at { DateTime.new(2026, 5, 1, 12, 01, 00) }
    requested_break_finished_at { DateTime.new(2026, 5, 1, 12, 58, 00) }
    reason { "MyText" }
  end
end
