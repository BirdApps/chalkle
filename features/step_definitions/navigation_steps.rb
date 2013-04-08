When /^they visit the "(.*?)" page$/ do |link|
  click_link link
end

Then /^they should see the "(.*?)" button$/ do |name|
  find_link name
end
