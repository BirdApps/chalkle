Given /^there is an admin user with no details$/ do
  FactoryGirl.create(:admin_user, name: "Test Admin", email: "test@chalkle.com", role: "super" )
end

Then /^they should see this admin user$/ do
  page.should have_content("test@chalkle.com")
end
