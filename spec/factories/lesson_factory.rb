FactoryGirl.define do
  factory :lesson do
    start_at Time.now + 2.days
    duration 1.5

    factory :cancelled_lesson do
      ignore do
        cancelled true
      end
    end
  end
end
