When /^they visit the Chalklers index page$/ do
  visit admin_chalklers_path
end

When /^they visit the New Chalkler form$/ do
  visit new_admin_chalkler_path
end

Then /^they should see channel checkboxes$/ do
  page.should have_content 'Wellington'
  page.should have_content 'Whanau'
end

Then /^they cannot see channel checkboxes$/ do
  page.should have_no_content 'Wellington'
end

When /^they create a chalkler with two channels$/ do
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries.clear
  fill_in 'chalkler_name', with: 'Jill'
  fill_in 'chalkler_email', with: 'jill@example.com'
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
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries.clear
  fill_in 'chalkler_name', with: 'Jill'
  fill_in 'chalkler_email', with: 'jill@example.com'
  click_button 'Create Chalkler'
end

When /^they create a chalkler with a Meetup id$/ do
  fill_in 'chalkler_name', with: 'Jill'
  fill_in 'chalkler_meetup_id', with: 12345678
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created with one channel$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  chalkler.channels includes(Channel.find_by_name 'Wellington')
end

When /^they create a chalkler without a channel$/ do
  fill_in 'chalkler_name', with: 'Jill'
  click_button 'Create Chalkler'
end

Then /^the new chalkler will receive a welcome email$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  email = ActionMailer::Base.deliveries.first
  email.to.should == [chalkler.email]
  email.parts.each do |p|
    p.body.should include(chalkler.reset_password_token)
  end
end

Then /^they should see an error message$/ do
  page.should have_content "can't be blank"
end

When /^the admin views "(.*?)'s" profile$/ do |name|
  chalkler = Chalkler.find_by_name name
  visit "/admin/chalklers/#{chalkler.id}"
end

When /^they trigger a password reset email$/ do
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries.clear
  click_link 'Send password reset email'
end

Then /^the chalkler "(.*?)" should receive a password reset email$/ do |name|
  chalkler = Chalkler.find_by_name name
  email = ActionMailer::Base.deliveries.first
  email.to.should == [chalkler.email]
  email.parts.each do |p|
    p.body.should include(chalkler.reset_password_token)
  end
end

Given /^the chalkler "(.*?)" has no email address$/ do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.update_attribute :email, nil
end

Then /^there should be no password reset button$/ do
  page.should have_no_content('Send password reset email')
end
