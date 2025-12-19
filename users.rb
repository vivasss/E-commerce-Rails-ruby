FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    role { :customer }
    active { true }
    
    trait :admin do
      role { :admin }
    end
    
    trait :with_address do
      after(:create) do |user|
        create(:address, user: user)
      end
    end
  end
end
