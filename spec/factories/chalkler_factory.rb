FactoryGirl.define do
  sequence(:uid) { |n| "1234567#{n}" }
  sequence(:email) { |n| "example_#{n}@example.com" }

  factory :chalkler do
    name "Ben Smith"
    email
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
