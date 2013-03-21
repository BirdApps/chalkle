When /^I am on the login page$/ do
  visit "/"
end

When /^I click "(.*?)"$/ do |button|
  click_link button
end

Then /^I should see "(.*?)"$/ do |string|
  page.should have_content string
end
