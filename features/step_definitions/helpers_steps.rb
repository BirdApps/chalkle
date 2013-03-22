When /^I am on the login page$/ do
  visit "/"
end

When /^I click "(.*?)"$/ do |button|
  click_link_or_button button
end

Then /^I should see "(.*?)"$/ do |string|
  page.should have_content string
end
When /^I fill in "(.*?)" with "(.*?)"$/ do |input_selector, desired_input|
  fill_in input_selector, :with => desired_input
end


