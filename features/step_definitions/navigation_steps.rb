When /^they visit the "(.*?)" page$/ do |link|
  click_link link
end

Then /^they should see the "(.*?)" button$/ do |name|
  find_link name
end

Then /^they should not see the "(.*?)" button$/ do |button|
  page.should_not have_selector(:link_or_button, button)
end

When /^they visit the "(.*?)" tab$/ do |link|
  click_link link
end

When /^they press the "(.*?)" button$/ do |button_name|
  click_link button_name
end
