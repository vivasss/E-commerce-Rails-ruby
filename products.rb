FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Produto #{n}" }
    description { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    short_description { Faker::Lorem.sentence }
    base_price { Faker::Commerce.price(range: 10..500) }
    sequence(:sku) { |n| "SKU-#{n.to_s.rjust(6, '0')}" }
    active { true }
    featured { false }
    association :category
    
    trait :featured do
      featured { true }
    end
    
    trait :on_sale do
      compare_at_price { base_price * 1.3 }
    end
    
    trait :with_variants do
      after(:create) do |product|
        create_list(:product_variant, 3, product: product)
      end
    end
  end
end
