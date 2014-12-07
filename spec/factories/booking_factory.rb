FactoryGirl.define do
  factory :booking do
    name 'booker books'
    status 'yes'
    guests 3
    payment_method 'credit_card'
    payment {|i| i.association(:payment) }
    chalkler { |i| i.association(:chalkler)}
    course { |i| i.association(:course)}
  end
  factory :booking_unpaid do
    name 'booker books'
    status 'yes'
    guests 3
    payment_method 'credit_card'
    chalkler { |i| i.association(:chalkler)}
    course { |i| i.association(:course)}
  end
end
