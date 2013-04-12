Given /^the "(.*?)" channel exists$/ do |name|
  channel = FactoryGirl.create(:channel, name: name, email: "#{name.downcase}@chalkle.com")
end
