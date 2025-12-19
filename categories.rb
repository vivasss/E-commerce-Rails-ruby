FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Categoria #{n}" }
    description { Faker::Lorem.paragraph }
    active { true }
    position { 0 }
    
    trait :with_parent do
      association :parent, factory: :category
    end
  end
end
