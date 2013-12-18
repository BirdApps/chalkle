FactoryGirl.define do
  sequence(:uid) { |n| "1234567#{n}" }
  sequence(:meetup_id) { |n| "1234567#{n}" }
  sequence(:email) { |n| "example_#{n}@example.com" }

  factory :chalkler do
    name "Ben Smith"
    email
    join_channels 'skip'
    bio "All about me!!"

    factory :meetup_chalkler do
      after(:build) do |user|
        user.identities << FactoryGirl.build(:meetup_identity)
      end
    end
  end

  factory :meetup_identity, class: 'OmniauthIdentity' do
    uid
    provider 'meetup'
    provider_data { MeetupApiStub::chalkler_response.to_json }
  end
end
