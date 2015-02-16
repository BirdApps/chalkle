FactoryGirl.define do
<<<<<<< HEAD
 # sequence(:email) { |n| "example_#{n}@example.com" }
=======
>>>>>>> dev

  factory :chalkler do
    name "Ben Smith"
    email {generate(:email)}
    join_providers 'skip'
    bio "All about me!!"

    factory :admin_chalkler do 
      role 'admin'
    end
    factory :super_chalkler do 
      role 'super'
    end


    factory :teacher_chalkler do 
      name "Mr. Bilbo"
      bio "I am a teacher"
      email
    end

  end

end
