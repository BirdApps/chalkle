FactoryGirl.define do
  factory :lesson do
    name Faker::Lorem.words
    meetup_id { (0...8).map{ rand(10) }.join }
    description Faker::Lorem.paragraph
    category
    # teacher

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
