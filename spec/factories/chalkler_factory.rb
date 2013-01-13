FactoryGirl.define do
  sequence(:meetup_id) { |n| "1234567#{n}" }

  factory :chalkler do
    name "Ben Smith"
    email "ben@hotmail.com"
    meetup_id
    bio "All about me!!"
  end
end
