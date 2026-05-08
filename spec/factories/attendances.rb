FactoryBot.define do
  factory :attendance do
    employee { nil }
    worked_on { "2026-05-07" }
    status { 1 }
    started_at { "2026-05-07 11:58:21" }
    finished_at { "2026-05-07 11:58:21" }
    break_started_at { "2026-05-07 11:58:21" }
    break_finished_at { "2026-05-07 11:58:21" }
  end
end
