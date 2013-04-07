#deprecated
When /^I visit the "(.*?)" page$/ do |link|
  click_link link
end

When /^they visit the "(.*?)" page$/ do |link|
  click_link link
end

#deprecated
When /^I follow "(.*?)"$/ do |link|
  click_link link
end

#deprecated
When /^I click the "(.*?)" button$/ do |name|
  click_button name
end

#deprecated
When /^I check "(.*?)"$/ do |selection|
  page.check selection
end

Then /^they should see the "(.*?)" button$/ do |name|
  find_link name
end
