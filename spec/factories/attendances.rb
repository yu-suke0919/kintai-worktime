FactoryBot.define do
  factory :attendance do
    employee { nil }
    worked_on { Date.new(2026, 5, 1) }
    status { :not_clocked }
    started_at { nil }
    finished_at { nil }
    break_started_at { nil }
    break_finished_at { nil }
    trait :eight_hour_shift do
      started_at { DateTime.new(2026, 5, 1, 8, 50, 00) }
      finished_at { DateTime.new(2026, 5, 1, 18, 10, 00) }
      break_started_at { DateTime.new(2026, 5, 1, 12, 01, 00) }
      break_finished_at { DateTime.new(2026, 5, 1, 12, 58, 00) }
    end
    trait :six_hour_shift do
      started_at { DateTime.new(2026, 5, 1, 10, 00, 00) }
      finished_at { DateTime.new(2026, 5, 1, 17, 00, 00) }
      break_started_at { DateTime.new(2026, 5, 1, 12, 01, 00) }
      break_finished_at { DateTime.new(2026, 5, 1, 12, 44, 00) }
    end

    trait :not_clocked do
      started_at { nil }
      finished_at { nil }
      break_started_at { nil }
      break_finished_at { nil }
    end
    trait :working_before_break do
      finished_at { nil }
      break_started_at { nil }
      break_finished_at { nil }
    end
    trait :on_break do
      finished_at { nil }
      break_finished_at { nil }
    end
    trait :working_after_break do
      finished_at { nil }
    end
    trait :properly_clocked do
    end
  end
end
