FactoryGirl.define do
  factory :chalkler do
    name "Ben Smith"
    email "ben@hotmail.com"
    meetup_id 12345678
    bio "All about me!!"
    groups {[ FactoryGirl.create(:group) ]}
  end
end
