FactoryGirl.define do
  factory :channel_contact do
    from "from@mailer.com"
    subject "subject for contact"
    message "messages are good"
    channel  {|i| i.association(:channel) } 
    chalkler {|i| i.association(:chalkler) }
  end
end
