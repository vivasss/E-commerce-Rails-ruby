FactoryBot.define do
  factory :address do
    association :user
    address_type { :shipping }
    name { Faker::Name.name }
    street { Faker::Address.street_name }
    number { Faker::Address.building_number }
    complement { Faker::Address.secondary_address }
    neighborhood { Faker::Address.community }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.zip_code }
    country { "BR" }
    phone { Faker::PhoneNumber.phone_number }
    default { false }
    
    trait :billing do
      address_type { :billing }
    end
    
    trait :default do
      default { true }
    end
  end
end
