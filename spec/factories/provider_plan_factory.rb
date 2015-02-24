FactoryGirl.define do
  sequence(:provider_plan_name) { |n| "community#{n}" }

  factory :provider_plan do
    name { generate :provider_plan_name }
    max_provider_admins 1
    max_teachers 1
    class_attendee_cost 2
    course_attendee_cost 2 
    max_free_class_attendees 20
    annual_cost 10
    processing_fee_percent 4
  end
end
