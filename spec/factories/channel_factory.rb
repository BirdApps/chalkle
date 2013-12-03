FactoryGirl.define do
  sequence(:channel_name) { |n| "channel#{n}" }

  factory :channel do
    name { generate(:channel_name) }
    email 'wellington@chalkle.com'
  end
end
