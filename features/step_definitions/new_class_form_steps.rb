# encoding: UTF-8
Given /^the "(.*?)" channel exists$/ do |name|
  FactoryGirl.create(:channel, name: name, email: "#{name.downcase}@chalkle.com")
end

Given /^the "(.*?)" category exists$/ do |category|
  FactoryGirl.create(:category, name: category)
end

Given /^I belong to the "(.*?)" channel$/ do |name|
  channel = Channel.find_by_name(name)
  @chalkler.channels << channel
  @chalkler.reload.channels == [channel]
end

Then /^I should see the New Class form$/ do
  page.should have_content('At chalkle°, anyone can be a teacher')
end

When /^I enter Title as "(.*?)"$/ do |title|
  fill_in 'teaching_title', with: title
end

When /^I enter What we are doing as "(.*?)"$/ do |doing|
  fill_in 'teaching_do_during_class', with: doing
end

When /^I enter What will we learn as "(.*?)"$/ do |learn|
  fill_in 'teaching_learning_outcomes', with: learn
end

When /^I select "(.*?)" as the primary category$/ do |category|
  select category, from: 'teaching_category_primary_id'
end

When /^I select "(.*?)" as the channel$/ do |channel|
  select channel, from: 'teaching[channel_id]'
end

Then /^I should see the new class confirmation message$/ do
  page.should have_content('Class submitted!')
end

Then /^"(.*?)" channel email link will be displayed$/ do |channel|
  channel = Channel.find_by_name channel
  page.should have_link(channel.email)
end
