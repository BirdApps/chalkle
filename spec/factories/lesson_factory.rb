FactoryGirl.define do
  factory :lesson do
    name "Learning fun"
    meetup_id
    meetup_url "http://meetup.com"
    description "You should really learn, it's fun!"
    cost 20

    factory :published_lesson do
      status Lesson::STATUS_1
      published_at { Time.now }
    end

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
