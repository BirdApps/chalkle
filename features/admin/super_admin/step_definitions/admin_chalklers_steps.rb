Given /^there is a chalkler with no details$/ do
  chalkler = FactoryGirl.create(:chalkler, name: "Test Chalkler")
end

Then /^they should see this chalkler$/ do
  page.should have_content("Test Chalkler")
end

Then /^they should see the New Chalkler form$/ do
  page.should have_content "New Chalkler"
end

When /^the super admin views "(.*?)'s" profile$/ do |name|
  chalkler = Chalkler.find_by_name name
  visit "/admin/chalklers/#{chalkler.id}"
  ActionMailer::Base.deliveries = []
end

Then /^the chalkler "(.*?)" should receive a password reset email$/ do |name|
  ActionMailer::Base.deliveries.length.should == 1
end

Given /^the chalkler "(.*?)" has no email address$/ do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.update_attribute :email, nil
end

Then /^super admin should not see a password reset button$/ do
  page.should have_no_link('Send password reset email')
end

Then /^the chalkler "(.*?)" should be deleted$/ do |name|
  page.should have_content "Chalkler was successfully destroyed"
  page.should_not have_content name 
end
