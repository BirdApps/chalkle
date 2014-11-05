FactoryGirl.define do
  sequence(:channel_name) { |n| "channel#{n}" }

  factory :channel do
    name { generate(:channel_name) }
    email 'wellington@chalkle.com'
    short_description "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat."
    channel_plan {|i| i.association :channel_plan }
  end
end
