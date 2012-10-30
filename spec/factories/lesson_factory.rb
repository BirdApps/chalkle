FactoryGirl.define do
  factory :lesson do
    name "Awesomeness class"
    meetup_id 12345678
    description "This is gonna be awesome!!!"
    category
    teacher
    lesson

    factory :lesson_with_bookings do
      ignore do
        bookings_count 5
      end

      after(:create) do |lesson, evaluator|
        FactoryGirl.create_list(:booking, evaluator.bookings_count, lesson: lesson)
      end
    end
  end
end
