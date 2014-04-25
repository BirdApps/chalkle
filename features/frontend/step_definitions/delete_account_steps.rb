# encoding: utf-8

Then /^the chalkler "(.*?)" is deleted$/ do |name|
  page.should have_content "Your account has been deleted."
end
