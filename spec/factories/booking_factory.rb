FactoryGirl.define do
  factory :booking do
    meetup_id 12345678
    lesson_id 123
    chalkler_id 12345678
    status "yes"
    guests 0
    paid nil
  end
end

