FactoryGirl.define do
  factory :lesson do
    
    start_at Time.now + 2.days
    duration 5400

    factory :cancelled_lesson do
      ignore do
        cancelled true
      end
    end

    factory :past_lesson do
      start_at Time.now - 2.days
    end
  end
end
