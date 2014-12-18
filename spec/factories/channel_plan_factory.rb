FactoryGirl.define do
  sequence(:channel_plan_name) { |n| "community#{n}" }

  factory :channel_plan do
    name { generate :channel_plan_name }
    max_channel_admins 1
    max_teachers 1
    class_attendee_cost 2
    course_attendee_cost 2 
    max_free_class_attendees 20
    annual_cost 10
    processing_fee_percent 4
  end
end
