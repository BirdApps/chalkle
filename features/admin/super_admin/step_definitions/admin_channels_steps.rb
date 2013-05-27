Given /^there is a channel with no details$/ do
  FactoryGirl.create(:channel, name: "Test Channel", url_name: "test_channel")
end

Then /^they should see this channel$/ do
  page.should have_content("Test Channel")
  page.should have_content("test_channel")
end