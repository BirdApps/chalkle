FactoryGirl.define do
  factory :provider_contact do
    from "from@mailer.com"
    subject "subject for contact"
    message "messages are good"
    provider  {|i| i.association(:provider) } 
    chalkler {|i| i.association(:chalkler) }
  end
end
