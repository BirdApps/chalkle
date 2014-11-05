FactoryGirl.define do
  factory :booking do
    status 'yes'
    guests 3
    payment_method 'credit_card'
    chalkler { |i| i.association(:chalkler)}
    course { |i| i.association(:course)}
  end
end
