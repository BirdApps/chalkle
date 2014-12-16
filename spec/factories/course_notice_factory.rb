FactoryGirl.define do 
  factory :course_notice do
    chalkler {|i| i.association :chalkler}
    course  {|i| i.association :published_course }
    body    "this is a course notice!"
    visible true

  end

end