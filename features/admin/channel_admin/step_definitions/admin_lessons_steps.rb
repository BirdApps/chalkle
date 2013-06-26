Given /^there is a lesson with no details in the "(.*?)" channel$/ do |name|
  channel = Channel.find_by_name(name)
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  lesson.channels << channel
end

Then /^they should see this lesson in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Test Class")
  page.should have_content(channel_name)
end

Then /^they should not see this lesson$/ do
  page.should_not have_content("Test Class")
end

Then /^they should produce a copy of this lesson$/ do
  page.should have_content("Copy of Test Class")
  page.should have_content("Test Class")
  Lesson.find_all_by_name("Test Class").count.should == 2
end

Then /^this lesson should be deleted$/ do
  lesson = Lesson.find_by_name("Test Class")
  page.should have_content("Lesson #{lesson.id} deleted!")
  lesson.visible.should be_false
end

Given /^the "(.*?)" channel has a teacher percentage of "(.*?)" percent$/ do |channel_name, teacher_percentage|
  channel = Channel.find_by_name(channel_name)
  channel.teacher_percentage = teacher_percentage.to_d/100.0
  channel.save
end

Given /^the "(.*?)" channel has a channel percentage of "(.*?)" percent$/ do |channel_name, channel_percentage|
  channel = Channel.find_by_name(channel_name)
  channel.channel_percentage = channel_percentage.to_d/100.0
  channel.save
end

When /^they fill in a teacher fee of "(.*?)"$/ do |teacher_cost|
  fill_in 'lesson_teacher_cost', with: teacher_cost
end

Then /^they should see an advertised price of "(.*?)"$/ do |price|
  page.execute_script("$('lesson_teacher_cost').keyup()")
  find_field('Advertised price').value.should eq price
end

Given /^this lesson has one paid booking by a chalkler named "(.*?)"$/ do |name|
  lesson = Lesson.find_by_name("Test Class")
  lesson.update_attributes(:status => "Published", :cost => 10)
  chalkler = FactoryGirl.create(:chalkler, name: name)
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, paid: false, status: 'yes', cost_override: 20)
end

When /^they view this lesson$/ do
  click_link "Lessons"
  click_link "View"
end

Then /^they should see a paid booking by "(.*?)"$/ do |name|
  page.should have_content(name)
  page.should have_content("yes")
end

Then /^this booking should be paid$/ do
  lesson = Lesson.find_by_name("Test Class")
  booking = lesson.bookings.first
end

Given(/^there is an unreviewed lesson with no details in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name(name)
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "Unreviewed")
  lesson.channels << channel
end

When(/^they fill in the lessons comments with "(.*?)"$/) do |comments|
  fill_in 'active_admin_comment_body', with: comments
  click_button 'Add Comment'
end

Given(/^"(.*?)" is teaching a lesson$/) do |name|
  teacher = Chalkler.find_by_name name
  lesson = FactoryGirl.create(:lesson, name: "Test class", teacher_id: teacher.id)
  lesson.channels = teacher.channels
end

Given(/^the chalkler "(.*?)" has no email$/) do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.update_attributes({:meetup_id => 1234567, :email => nil}, :as => :admin)
end
