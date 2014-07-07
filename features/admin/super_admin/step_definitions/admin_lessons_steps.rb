Given /^there is a course with no details$/ do
  FactoryGirl.create(:course, name: "Test Class")
end

Then /^they should see this course$/ do
  page.should have_content("Test Class")
end

Given(/^there is a paid course in the past$/) do
  teacher = FactoryGirl.create(:chalkler, name: "Test chalkler")
  course = FactoryGirl.create(:course, name: "Test class", teacher_cost: 5, cost: 10, status: "Published", start_at: 3.days.ago, teacher_id: teacher.id, channel: FactoryGirl.create(:channel))
  FactoryGirl.create(:booking, chalkler_id: teacher.id, course_id: course.id, paid: false, guests: 10)
end

When(/^they click into this course$/) do
  click_link "Courses"
  click_link "View"
end

Then(/^they should see the payment summary$/) do
  page.should have_content("Here is a summary of Chalkle's payment to you for this class")
end

When(/^they edit this course$/) do
  click_link "Courses"
  click_link "Edit"
end

Given(/^there is a paid course in the future$/) do
  teacher = FactoryGirl.create(:chalkler, name: "Test chalkler")
  course = FactoryGirl.create(:course, name: "Test class", teacher_cost: 5, cost: 10, status: "Published", start_at: 10.days.from_now, teacher_id: teacher.id, channel: FactoryGirl.create(:channel))
end

When(/^they fill in a teacher cost of "(.*?)"$/) do |teacher_cost|
  fill_in 'course_teacher_cost', with: teacher_cost
end

When(/^they fill in a channel percentage of "(.*?)" percent$/) do |channel_percentage|
  fill_in 'course_channel_percentage_override', with: channel_percentage
end

When(/^they fill in a chalkle percentage of "(.*?)" percent$/) do |chalkle_percentage|
  fill_in 'course_channel_percentage_override', with: chalkle_percentage
end

Then(/^they should see a calculated advertised price of "(.*?)"$/) do |price|
  page.execute_script("$('course_teacher_cost').keyup()")
  find_field('Advertised price').value.should eq price
end
