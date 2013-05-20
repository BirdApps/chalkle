Given /^there is an unreconciled payment with no details$/ do
  Payment.create!([xero_id: "abc", total: 10], :as => :admin)
end

Then /^they should see this payment$/ do
  page.should have_content("10")
end

Given /^there is a lesson with no details$/ do
  Lesson.create!([name: "Test Class"], :as => :admin)
end

Then /^they should see this lesson$/ do
  page.should have_content("Test Class")
end


