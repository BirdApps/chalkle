FactoryGirl.define do
  factory :category do
    name "Just a category"
    groups {[ FactoryGirl.create(:group) ]}
  end
end
