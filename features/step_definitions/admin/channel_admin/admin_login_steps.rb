Given /^"(.*?)" is a channel admin$/ do |name|
  FactoryGirl.create(:admin_user, name: name, email: "#{name.downcase}@chalkle.com", password: 'password', role: 'channel admin')
end

When /^the admin "(.*?)" logs in$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password'
  click_button "Login"
end

Then /^they should be logged in$/ do
  page.should have_selector('h2', :text => 'Dashboard')
end

When /^the admin "(.*?)" logs in with an incorrect password$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password2'
  click_button "Login"
end

Then /^they should not be logged in$/ do
  page.should have_no_selector('h2', :text => 'Dashboard')
end
