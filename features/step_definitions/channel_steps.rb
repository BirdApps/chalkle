Given /^the "(.*?)" channel exists$/ do |name|
  channel = FactoryGirl.create(:channel, name: name, email: "#{name.downcase}@chalkle.com", teacher_percentage: 0.01, channel_percentage: 0.01)
end
