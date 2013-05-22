Given /^there is a chalkler with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  chalkler = FactoryGirl.create(:chalkler, name: "Test Chalkler")
  chalkler.channels << channel
end

# Then /^they should see this chalkler$/ do
#   page.should have_content("Test Chalkler")
# end

# When /^they visit the Chalklers index page$/ do
#   visit admin_chalklers_path
# end

# Then /^they should see the New Chalkler form$/ do
#   page.should have_content "New Chalkler"
# end

# When /^they visit the New Chalkler form$/ do
#   visit new_admin_chalkler_path
# end

# When /^they create a chalkler without a channel$/ do
#   fill_in 'chalkler_name', with: 'Toby'
#   click_button 'Create Chalkler'
# end

# Then /^they should see an error message$/ do
#   page.should have_content "can't be blank"
# end

# Then /^they cannot see channel checkboxes$/ do
#   page.should have_no_content 'Wellington'
# end

# When /^they create a chalkler$/ do
#   admin_user = AdminUser.find_by_name 'Jill'
#   fill_in 'chalkler_name', with: 'Toby'
#   ActionMailer::Base.deliveries = []
#   click_button 'Create Chalkler'
# end

# Then /^a new chalkler is created with one channel$/ do
#   chalkler = Chalkler.find_by_name 'Toby'
#   chalkler.channels includes(Channel.find_by_name 'Wellington')
# end

# Then /^the new chalkler will receive a password reset email$/ do
#   ActionMailer::Base.deliveries.length.should == 1
# end

# Then /^they should see channel checkboxes$/ do
#   page.should have_content 'Wellington'
#   page.should have_content 'Whanau'
# end

# When /^they create a chalkler with two channels$/ do
#   fill_in 'chalkler_name', with: 'Jill'
#   page.check 'Whanau'
#   page.check 'Wellington'
#   ActionMailer::Base.deliveries = []
#   click_button 'Create Chalkler'
# end

# Then /^a new chalkler is created with two channels$/ do
#   chalkler = Chalkler.find_by_name 'Jill'
#   chalkler.channels includes(Channel.find_by_name 'Wellington')
#   chalkler.channels includes(Channel.find_by_name 'Whanau')
# end

# When /^the admin views "(.*?)'s" profile$/ do |name|
#   chalkler = Chalkler.find_by_name name
#   visit "/admin/chalklers/#{chalkler.id}"
# end

# When /^they trigger a password reset email$/ do
#   ActionMailer::Base.deliveries = []
#   click_link 'Send password reset email'
# end

# Then /^the chalkler "(.*?)" should receive a password reset email$/ do |name|
#   ActionMailer::Base.deliveries.length.should == 1
# end

# Given /^the chalkler "(.*?)" has no email address$/ do |name|
#   chalkler = Chalkler.find_by_name name
#   chalkler.update_attribute :email, nil
# end

# Then /^there should be no password reset button$/ do
#   page.should have_no_content('Send password reset email')
# end
