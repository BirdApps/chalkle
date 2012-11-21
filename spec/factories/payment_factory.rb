FactoryGirl.define do
  factory :payment do
    booking
    xero_id "d4ec6b9e-df05-4c06-834d-7ea174293bf6"
    xero_contact_id "6d8d2d95-3ccf-46ec-ae58-2582f9b01e9d"
    xero_contact_name { "#{Faker::Name.name} (#{Faker::Internet.email})" }
    date  { Date.today }
    complete_record_downloaded { [true, false].sample }
    total { rand(10).to_f }
    reconciled { [true, false].sample }
  end
end

