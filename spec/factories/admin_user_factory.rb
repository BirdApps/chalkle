FactoryGirl.define do
  sequence(:email) { |n| "jill#{n}@hotmail.com" }

  factory :admin_user do
    name "Jill Scott"
    email
    role "super"

    factory :super_admin_user do
      role "super"
    end

    factory :group_admin_user do
      role "group admin"
    end
  end
end
