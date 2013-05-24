When /^they visit the "(.*?)" page$/ do |link|
  click_link link
end

Then /^they should see the "(.*?)" button$/ do |name|
  find_link name
end

When /^they visit the "(.*?)" tab$/ do |link|
  click_link link
end

When /^they press the "(.*?)" button$/ do |button_name|
  click_link button_name
end
