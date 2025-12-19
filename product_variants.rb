FactoryBot.define do
  factory :product_variant do
    sequence(:name) { |n| "Variante #{n}" }
    sequence(:sku) { |n| "VAR-#{n.to_s.rjust(6, '0')}" }
    price { Faker::Commerce.price(range: 10..500) }
    stock_quantity { rand(1..100) }
    active { true }
    position { 0 }
    weight { rand(0.1..5.0).round(2) }
    association :product
    
    trait :out_of_stock do
      stock_quantity { 0 }
    end
    
    trait :low_stock do
      stock_quantity { rand(1..5) }
    end
    
    trait :with_options do
      option1_name { "Cor" }
      option1_value { Faker::Color.color_name }
      option2_name { "Tamanho" }
      option2_value { ["P", "M", "G", "GG"].sample }
    end
  end
end
