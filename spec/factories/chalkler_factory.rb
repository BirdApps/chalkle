FactoryGirl.define do
  sequence(:meetup_id) { |n| "1234567#{n}" }
  sequence(:email) { |n| "example_#{n}@example.com" }

  factory :chalkler do
    name "Ben Smith"
    email
    bio "All about me!!"
    join_channels 'skip'

    factory :meetup_chalkler do
      meetup_id
      meetup_data { MeetupApiStub::chalkler_response.to_json }
    end
  end
end
