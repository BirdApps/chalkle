FactoryGirl.define do

  factory :the_user do
    chalkler {|i| i.association(:chalkler) }
  end

end
