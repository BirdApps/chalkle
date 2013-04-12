When /^They are on the login page$/ do 
  visit "/"
end

When /^They click "(.*?)"$/ do |button|
  click_link_or_button button
end

Then /^They should see "(.*?)"$/ do |string|
  page.should have_content string
end
When /^They fill in "(.*?)" with "(.*?)"$/ do |input_selector, desired_input|
  fill_in input_selector, :with => desired_input
end


