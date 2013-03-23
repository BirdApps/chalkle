FactoryGirl.define do
  sequence(:meetup_id) { |n| "1234567#{n}" }

  factory :chalkler do
    name "Ben Smith"
    email "ben@hotmail.com"
    meetup_id
    bio "All about me!!"
    gst "234 78 990"
    password "password"
  end
end
