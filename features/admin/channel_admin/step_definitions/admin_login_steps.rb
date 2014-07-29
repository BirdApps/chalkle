Given /^"(.*?)" is a channel admin$/ do |name|
  admin_user = AdminUser.find_by_name(name)
  if(admin_user)
    admin_user.role = 'channel admin'
    admin_user.save
  else
    FactoryGirl.create(:admin_user, name: name, email: "#{name.downcase}@chalkle.com", password: 'password', role: 'channel admin')
  end
end

When /^the channel admin "(.*?)" logs in$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password'
  click_button "Login"
end

Then /^they should be logged in as channel admin$/ do
  page.should have_selector('h2', :text => 'Dashboard')
  page.should have_no_link('Admin User')
end

When /^the channel admin "(.*?)" logs in with an incorrect password$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password2'
  click_button "Login"
end

Then /^they should not be logged in as channel admin$/ do
  page.should have_no_selector('h2', :text => 'Dashboard')
end