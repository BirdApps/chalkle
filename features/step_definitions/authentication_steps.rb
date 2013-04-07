Given /^the chalkler "(.*?)" is authenticated$/ do |name|
  chalkler = Chalkler.find_by_name name
  visit '/chalklers/sign_in'
  fill_in 'chalkler_email', :with => chalkler.email
  fill_in 'chalkler_password', :with => 'password'
  click_button 'Sign in'
  page.has_content? 'Signed in successfully.'
end

Given /^the admin "(.*?)" is authenticated$/ do |name|
  admin_user = AdminUser.find_by_name name
  visit '/admin/login'
  fill_in 'admin_user_email', :with => admin_user.email
  fill_in 'admin_user_password', :with => 'password'
  click_button 'Login'
end
