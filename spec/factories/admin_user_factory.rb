FactoryGirl.define do
  factory :admin_user do
    name Faker::Name.name
    email Faker::Internet.email
    role { ["super", "group admin"].sample }
    groups {[ FactoryGirl.create(:group) ]}

    factory :super_admin_user do
      role "super"
    end

    factory :group_admin_user do
      role "group admin"
    end
  end
end
