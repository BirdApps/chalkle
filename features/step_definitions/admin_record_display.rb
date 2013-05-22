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

Given /^there is a channel with no details$/ do
  Channel.create!([name: "Test Channel", url_name: "test_channel"], :as => :admin)
end

Then /^they should see this channel$/ do
  page.should have_content("Test Channel")
  page.should have_content("test_channel")
end

Given /^there is a chalkler with no details$/ do
  channel = FactoryGirl.create(:channel)
  Chalkler.create!([name: "Test Chalkler", email: "tests@abc.com", :join_channels => [channel.id]], :as => :admin)
end

Then /^they should see this chalkler$/ do
  page.should have_content("Test Chalkler")
end

Given /^there is a category with no details$/ do
  Category.create!([name: "Test Category"], :as => :admin)
end

Then /^they should see this category$/ do
  page.should have_content("Test Category")
end

Given /^there is a booking with no details$/ do
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  chalkler = FactoryGirl.create(:chalkler)
  Booking.create!([lesson_id: lesson.id, chalkler_id: chalkler.id, payment_method: 'free', status: 'yes'], :as => :admin)
end

Then /^they should see this booking$/ do
  page.should have_content("Test Class")
end

Given /^there is an admin user with no details$/ do
  AdminUser.create!([name: "Test Admin", email: "test@chalkle.com", role: "super"], :as => :admin)
end

Then /^they should see this admin user$/ do
  page.should have_content("test@chalkle.com")
end

