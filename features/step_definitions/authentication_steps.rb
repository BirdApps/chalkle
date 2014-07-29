Given /^the chalkler "(.*?)" is authenticated$/ do |name|
  chalkler = Chalkler.find_by_name name
  visit '/chalklers/sign_in'
  fill_in 'Email', :with => chalkler.email
  fill_in 'Password', :with => 'password'
  click_button 'Sign in'
end

Given /^the admin "(.*?)" is authenticated$/ do |name|
  admin_user = AdminUser.find_by_name name
  if(admin_user.current_sign_in_at.nil?)
    visit '/admin/login'
    fill_in 'admin_user_email', :with => admin_user.email
    fill_in 'admin_user_password', :with => 'password'
    click_button 'Login'
  end
end
