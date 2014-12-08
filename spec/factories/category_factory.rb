FactoryGirl.define do
  
  sequence(:name) { |n| "Just a category #{n}" }

  factory :category do
    name { generate(:name) }
  end
end
