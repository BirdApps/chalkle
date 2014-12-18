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

    factory :teacher_chalkler do 
      name "Mr. Bilbo"
      bio "I am a teacher"
      email
    end

  end

end
