FactoryGirl.define do
  factory :category do
    name { Faker::Lorem.words.join(" ") }
  end
end
