FactoryBot.define do
  factory :employee do
    name                  { "name" }
    email                 { "test@gmail.com" }
    password              { "111111" }
    password_confirmation { "111111" }
  end
end
