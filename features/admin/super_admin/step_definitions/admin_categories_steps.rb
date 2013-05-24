Given /^there is a category with no details$/ do
  FactoryGirl.create(:category, name: "Test Category")
end

Then /^they should see this category$/ do
  page.should have_content("Test Category")
end
