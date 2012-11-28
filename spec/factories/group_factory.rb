FactoryGirl.define do
  factory :group do
    name Faker::Address.city
    url_name { Faker::Internet.user_name(name) }
  end
end
