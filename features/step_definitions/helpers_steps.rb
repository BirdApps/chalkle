When /^They are on the login page$/ do
  visit root_path
end

When /^they click on the "(.*?)" button$/ do |button|
  click_link_or_button button
end

Then /^they should see "(.*?)"$/ do |string|
  page.should have_content string
end

When /^they fill in "(.*?)" with "(.*?)"$/ do |input_selector, desired_input|
  fill_in input_selector, :with => desired_input
end
