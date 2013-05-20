Then /^they should see channel checkboxes$/ do
  page.should have_content 'Wellington'
  page.should have_content 'Whanau'
end

Then /^they cannot see channel checkboxes$/ do
  page.should have_no_content 'Wellington'
end

When /^they create a chalkler with two channels$/ do
  fill_in 'chalkler_name', with: 'Jill'
  page.check 'Whanau'
  page.check 'Wellington'
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created with two channels$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  chalkler.channels includes(Channel.find_by_name 'Wellington')
  chalkler.channels includes(Channel.find_by_name 'Whanau')
end

When /^they create a chalkler$/ do
  admin_user = AdminUser.find_by_name 'John'
  fill_in 'chalkler_name', with: 'Jill'
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created with one channel$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  chalkler.channels includes(Channel.find_by_name 'Wellington')
end

When /^they trigger a password reset email$/ do
  ActionMailer::Base.deliveries = []
  click_link 'Send password reset email'
end

Then /^the chalkler "(.*?)" should receive a password reset email$/ do |name|
  ActionMailer::Base.deliveries.length.should == 1
end

Given /^the chalkler "(.*?)" has no email address$/ do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.update_attribute :email, nil
end

Then /^there should be no password reset button$/ do
  page.should have_no_content('Send password reset email')
end
