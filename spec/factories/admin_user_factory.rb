FactoryGirl.define do
  factory :admin_user do
    name "Jill Scott"
    email "jill@hotmail.com"
    role "super"
    groups {[ FactoryGirl.create(:group) ]}

    factory :super_admin_user do
      role "super"
    end

    factory :group_admin_user do
      role "group admin"
    end
  end
end
