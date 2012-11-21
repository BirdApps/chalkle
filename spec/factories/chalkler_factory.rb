FactoryGirl.define do
  factory :chalkler do
    name Faker::Name.name
    email Faker::Internet.email
    meetup_id { (0...8).map{ rand(10) }.join }
    bio Faker::Lorem.paragraph
  end
end
