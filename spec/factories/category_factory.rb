FactoryGirl.define do
  factory :category do
    name { Faker::Lorem.words.join(" ") }
    groups {[ FactoryGirl.create(:group) ]}
  end
end
