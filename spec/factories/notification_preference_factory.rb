FactoryGirl.define do 
  factory :notification_preference do
    chalkler {|i| i.association :chalkler }
  end
end