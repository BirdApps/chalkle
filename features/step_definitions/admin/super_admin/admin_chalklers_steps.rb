Given /^there is a chalkler with no details$/ do
  chalkler = FactoryGirl.create(:chalkler, name: "Test Chalkler")
  chalkler.channels << FactoryGirl.create(:channel)
end

Then /^they should see this chalkler$/ do
  page.should have_content("Test Chalkler")
end

When /^they visit the Chalklers index page$/ do
  visit admin_chalklers_path
end

Then /^they should see the New Chalkler form$/ do
  page.should have_content "New Chalkler"
end

When /^they visit the New Chalkler form$/ do
  visit new_admin_chalkler_path
end

When /^they create a chalkler without a channel$/ do
  fill_in 'chalkler_name', with: 'Toby'
  click_button 'Create Chalkler'
end

Then /^they should see an error message$/ do
  page.should have_content "can't be blank"
end

When /^the admin views "(.*?)'s" profile$/ do |name|
  chalkler = Chalkler.find_by_name name
  visit "/admin/chalklers/#{chalkler.id}"
end


