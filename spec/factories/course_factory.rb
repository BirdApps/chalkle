FactoryGirl.define do
  factory :course do
    lessons { |i| [i.association(:lesson)]}
    provider { |i| i.association(:provider) }
    teacher { |i| i.association(:provider_teacher) }
    
    name "Learn Foo with Bar"
    learning_outcomes "Bar the foo, it's all about how far you can boo"
    do_during_class "You will take a foo and bar it"
    cost 20
    venue_address "3 Courtany Place, Wellington, New Zealand"


    status 'Published'
    teacher_pay_type 'Fee per attendee'

    factory :flat_fee_course do
      teacher_pay_type 'Flat fee'
    end

    factory :free_course do 
      teacher_pay_type 'Flat fee'
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
