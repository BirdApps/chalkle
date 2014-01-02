FactoryGirl.define do
  sequence(:region_name) { |n| "region#{n}" }

  factory :region do
    name { generate(:region_name) }
  end
end
