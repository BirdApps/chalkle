Given /^the "(.*?)" channel exists$/ do |name|
  FactoryGirl.create(:channel, name: name, email: "#{name.downcase}@chalkle.com", teacher_percentage: 0.01, channel_percentage: 0.01)
end

Given(/^they visit the "(.*?)" channel page$/) do |channel_name|
  channel = Channel.where(name: channel_name).first
  visit channel_path(channel)
end