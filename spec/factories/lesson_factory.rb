FactoryGirl.define do
  factory :lesson do
    name "Learning fun"
    meetup_id
    description "You should really learn, it's fun!"
    cost 20

    factory :lesson_with_bookings do
      ignore do
        bookings_count { rand(5) }
      end

      after(:create) do |lesson, evaluator|
        FactoryGirl.create_list(:booking, evaluator.bookings_count, lesson: lesson)
      end
    end
  end
end
