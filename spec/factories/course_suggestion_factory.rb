FactoryGirl.define do
  factory :course_suggestion do
    name "Suggesting fun"
    description "You should really learn, suggest it, it's fun!"

    after(:build) do |course_suggestion|
      course_suggestion.join_providers = [FactoryGirl.create(:provider).id]
    end
  end
end
