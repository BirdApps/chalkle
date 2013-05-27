Given /^"(.*?)" is a super admin$/ do |name|
  FactoryGirl.create(:admin_user, name: name, email: "#{name.downcase}@chalkle.com", password: 'password', role: 'super')
end

When /^the super admin "(.*?)" logs in$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password'
  click_button "Login"
end

Then /^they should be logged in as super admin$/ do
  page.should have_selector('h2', :text => 'Dashboard')
  page.should have_link('Admin User')
end

When /^the super admin "(.*?)" logs in with an incorrect password$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password2'
  click_button "Login"
end

Then /^they should not be logged in as super admin$/ do
  page.should have_no_selector('h2', :text => 'Dashboard')
  page.should have_no_link('Admin User')
end
