Given /^"(.*?)" is a channel admin$/ do |email|
  AdminUser.create(email: email, password: 'password', password_confirmation: 'password', role: "channel admin")
end

When /^I login as "(.*?)"$/ do |email|
  visit '/admin/login'
  fill_in "admin_user_email", :with => email
  fill_in "admin_user_password", :with => "password"
  click_button "Login"
end

Then /^I should be logged in$/ do
  page.should have_selector('h2', :text => 'Dashboard')
end

Then /^I should not be logged in$/ do
  page.should have_no_selector('h2', :text => 'Dashboard')
end

When /^I login as "(.*?)" with an incorrect password$/ do |email|
  visit '/admin/login'
  fill_in "admin_user_email", :with => email
  fill_in "admin_user_password", :with => "password2"
  click_button "Login"
end

Given /^"(.*?)" received a password reset token$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I click on the link$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be able to change my passwords$/ do
  pending # express the regexp above with the code you wish you had
end
