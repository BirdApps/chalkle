FactoryGirl.define do
  factory :course do
    name "Learning fun"
    description "You should really learn, it's fun!"
    cost 20
    lessons { |i| [i.association(:lesson)]}
    channel { |i| i.association(:channel) }
    teacher { |i| i.association(:channel_teacher) }

    factory :published_course do
      status 'Published'
      published_at { Time.now }
    end

    factory :course_without_lessons do
      lessons []
    end

    factory :course_with_bookings do
      ignore do
        bookings_count { rand(5) }
      end

      after(:create) do |course, evaluator|
        FactoryGirl.create_list(:booking, evaluator.bookings_count, course: course)
      end
    end

    factory :course_with_no_lessons do
      after(:create) do |course|
        course.lessons = []
      end
    end

  end
end
