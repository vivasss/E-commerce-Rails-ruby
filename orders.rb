FactoryBot.define do
  factory :order do
    association :user
    status { :pending }
    subtotal { 100.00 }
    discount_amount { 0 }
    shipping_amount { 15.00 }
    tax_amount { 0 }
    total { 115.00 }
    shipping_name { Faker::Name.name }
    shipping_street { Faker::Address.street_name }
    shipping_number { Faker::Address.building_number }
    shipping_neighborhood { Faker::Address.community }
    shipping_city { Faker::Address.city }
    shipping_state { Faker::Address.state_abbr }
    shipping_postal_code { Faker::Address.zip_code }
    shipping_country { "BR" }
    billing_name { Faker::Name.name }
    billing_street { Faker::Address.street_name }
    billing_number { Faker::Address.building_number }
    billing_neighborhood { Faker::Address.community }
    billing_city { Faker::Address.city }
    billing_state { Faker::Address.state_abbr }
    billing_postal_code { Faker::Address.zip_code }
    billing_country { "BR" }
    
    trait :confirmed do
      status { :confirmed }
      confirmed_at { Time.current }
    end
    
    trait :shipped do
      status { :shipped }
      shipped_at { Time.current }
    end
    
    trait :delivered do
      status { :delivered }
      delivered_at { Time.current }
    end
    
    trait :with_items do
      after(:create) do |order|
        create_list(:order_item, 2, order: order)
      end
    end
  end
end
