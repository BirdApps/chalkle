Given /^there is a chalkler with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  chalkler = FactoryGirl.create(:chalkler, name: "Test Chalkler")
  chalkler.channels << channel
end

Then /^they should see this chalkler in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Test Chalkler")
  page.should have_content(channel_name)
end

Then /^they should not see this chalkler$/ do
  page.should_not have_content("Test Chalkler")
end

Then /^they should see the New Chalkler form for this channel$/ do
  page.should have_content "New Chalkler"
end

When /^they visit the New Chalkler form$/ do
  visit new_admin_chalkler_path
end

When /^they create a chalkler without a channel$/ do
  fill_in 'chalkler_name', with: 'Toby'
  click_button 'Create Chalkler'
end

Then /^they should see an error message$/ do
  page.should have_content "can't be blank"
end

Then /^they cannot see channel checkboxes$/ do
  page.should have_no_content 'Wellington'
end

When /^they create a chalkler$/ do
  fill_in 'chalkler_name', with: 'Toby'
  fill_in 'chalkler_email', with: 'abc@test.com'
  ActionMailer::Base.deliveries = []
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created in the "(.*?)" channel$/ do |channel_name|
  chalkler = Chalkler.find_by_name 'Toby'
  chalkler.channels includes(Channel.find_by_name channel_name)
end

Then /^the new chalkler will receive a password reset email$/ do
  ActionMailer::Base.deliveries.length.should == 1
end

Then /^they should see channel checkboxes$/ do
  page.should have_content 'Wellington'
  page.should have_content 'Whanau'
end

When /^they create a chalkler with two channels$/ do
  fill_in 'chalkler_name', with: 'Jill'
  fill_in 'chalkler_email', with: 'abc@test.com'
  page.check 'Whanau'
  page.check 'Wellington'
  ActionMailer::Base.deliveries = []
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created with two channels$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  chalkler.channels includes(Channel.find_by_name 'Wellington')
  chalkler.channels includes(Channel.find_by_name 'Whanau')
end

When /^the channel admin views "(.*?)'s" profile$/ do |name|
  chalkler = Chalkler.find_by_name name
  visit "/admin/chalklers/#{chalkler.id}"
  ActionMailer::Base.deliveries = []
end

Then /^the chalkler "(.*?)" in this channel should receive a password reset email$/ do |name|
  ActionMailer::Base.deliveries.length.should == 1
end

Then /^channel admin should not see a password reset button$/ do
  page.should have_no_link('Send password reset email')
end

Given(/^"(.*?)" is the teacher for the lesson "(.*?)"$/) do |teacher_name, lesson_name|
  teacher = Chalkler.find_by_name teacher_name
  lesson = FactoryGirl.create(:lesson, name: lesson_name, teacher_id: teacher.id, channel: teacher.channels.first)
end

Then(/^they should see the lesson "(.*?)"$/) do |name|
  page.should have_content(name)
end

Given(/^"(.*?)" attended the lesson "(.*?)"$/) do |student_name, lesson_name|
  student = Chalkler.find_by_name student_name
  lesson = FactoryGirl.create(:lesson, name: lesson_name, channel: student.channels.first)
  FactoryGirl.create(:booking, lesson_id: lesson.id, chalkler_id: student.id, status: 'yes')
end

Given(/^"(.*?)" did not attend the lesson "(.*?)"$/) do |student_name, lesson_name|
  student = Chalkler.find_by_name student_name
  lesson = FactoryGirl.create(:lesson, name: lesson_name, channel: student.channels.first)
  FactoryGirl.create(:booking, lesson_id: lesson.id, chalkler_id: student.id, status: 'no')
end

Then(/^they should not see the lesson "(.*?)"$/) do |name|
  page.should_not have_content(name)
end

When(/^they view this chalkler$/) do
  click_link "Chalklers"
  click_link "View"
end

When(/^they fill in the chalkler comments with "(.*?)"$/) do |comments|
  fill_in 'active_admin_comment_body', with: comments
  click_button 'Add Comment'
end

When(/^they return to the chalkler index page$/) do
  visit admin_chalklers_path
end

