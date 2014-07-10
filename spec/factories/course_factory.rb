FactoryGirl.define do
  factory :course do
    name "Learning fun"
    description "You should really learn, it's fun!"
    cost 20
    lessons { |i| [i.association(:lesson)]}

    factory :published_course do
      status 'Published'
      published_at { Time.now }
    end

    factory :course_with_bookings do
      ignore do
        bookings_count { rand(5) }
      end

      after(:create) do |course, evaluator|
        FactoryGirl.create_list(:booking, evaluator.bookings_count, course: course)
      end
    end
  end
end
