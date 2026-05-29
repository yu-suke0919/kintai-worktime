FactoryBot.define do
  factory :attendance_edit_request do
    attendance { nil }
    employee { nil }
    approved_by_id { 1 }
    approved_at { "2026-05-11 13:40:43" }
    status { 1 }
    requested_started_at { "2026-05-11 13:40:43" }
    requested_finished_at { "2026-05-11 13:40:43" }
    reason { "MyText" }
  end
end
