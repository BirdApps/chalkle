FactoryGirl.define do
  factory :lesson_suggestion do
    name "Suggesting fun"
    description "You should really learn, suggest it, it's fun!"

    after(:build) do |lesson_suggestion|
      lesson_suggestion.join_channels = [FactoryGirl.create(:channel).id]
    end
  end
end
