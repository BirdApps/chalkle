FactoryGirl.define do
  sequence(:provider_name) { |n| "provider#{n}" }

  factory :provider do
    name { generate(:provider_name) }
    email 'wellington@chalkle.com'
    short_description "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat."
    provider_plan {|i| i.association :provider_plan }
  end
end
