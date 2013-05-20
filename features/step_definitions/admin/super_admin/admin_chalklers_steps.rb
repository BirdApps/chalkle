Given /^there is a chalkler with no details$/ do
  chalkler = FactoryGirl.create(:chalkler, name: "Test Chalkler")
  chalkler.channels << FactoryGirl.create(:channel)
end

Then /^they should see this chalkler$/ do
  page.should have_content("Test Chalkler")
end