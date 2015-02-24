FactoryGirl.define do
  sequence(:xero_id) { |n| "d4ec6b9e-df05-4c06-834d-7ea174293bfxi#{n}" }

  factory :payment do
    xero_id
    xero_contact_id "6d8d2d95-3ccf-46ec-ae58-2582f9b01e9d"
    xero_contact_name "John Smith"
    date  { Date.today }
    complete_record_downloaded false
    total 20
    reconciled false
    chalkler {|i| i.association :chalkler }
  end
end

