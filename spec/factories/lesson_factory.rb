FactoryGirl.define do
  factory :lesson do
    name "Learning fun"
    meetup_id 12345678
    description "You should really learn, it's fun!"
    category
    cost 20
    groups {[ FactoryGirl.create(:group) ]}

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
