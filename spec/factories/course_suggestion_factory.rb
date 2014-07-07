FactoryGirl.define do
  factory :course_suggestion do
    name "Suggesting fun"
    description "You should really learn, suggest it, it's fun!"

    after(:build) do |course_suggestion|
      course_suggestion.join_channels = [FactoryGirl.create(:channel).id]
    end
  end
end
