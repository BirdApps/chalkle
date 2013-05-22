Given /^there is a lesson with no details$/ do
  FactoryGirl.create(:lesson, name: "Test Class")
end

Then /^they should see this lesson$/ do
  page.should have_content("Test Class")
end