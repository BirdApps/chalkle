FactoryGirl.define do
  sequence(:email) { |n| "example_#{n}@example.com" }

  factory :chalkler do
    name "Ben Smith"
    email {generate(:email)}
    join_channels 'skip'
    bio "All about me!!"

    factory :admin_chalkler do 
      role 'admin'
    end

  end

end
