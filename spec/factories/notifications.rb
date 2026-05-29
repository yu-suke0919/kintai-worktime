FactoryBot.define do
  factory :notification do
    recipient_employee { nil }
    notification_type { 1 }
    notifiable { nil }
    read_at { "2026-05-28 10:24:16" }
    message_text { "MyText" }
  end
end
