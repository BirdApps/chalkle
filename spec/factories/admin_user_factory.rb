FactoryGirl.define do
  factory :admin_user do
    name "Jill Scott"
    email
    role "super"

    factory :super_admin_user do
      role "super"
    end

    factory :channel_admin_user do
      role "channel admin"
    end
  end
end
