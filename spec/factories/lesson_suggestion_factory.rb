FactoryGirl.define do
  factory :lesson_suggestion do
    name "Suggesting fun"
    description "You should really learn, suggest it, it's fun!"
    join_channels [1]
  end
end
