FactoryGirl.define do
  factory :booking do
    meetup_id
    status 'yes'
    guests 3
    paid false
    payment_method 'meetup'
    chalkler
    lesson
  end
end
