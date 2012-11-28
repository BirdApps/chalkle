FactoryGirl.define do
  factory :booking do
    meetup_id { (0...8).map{ rand(10) }.join }
    status { ["yes", "no", "waitlist"].sample }
    guests { rand(5) }
    paid { [true, false].sample }
    chalkler
    lesson
  end
end
