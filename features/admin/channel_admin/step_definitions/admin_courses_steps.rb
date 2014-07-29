Given /^there is a course with no details in the "(.*?)" channel$/ do |name|
  channel = Channel.find_by_name(name)
  course = FactoryGirl.create(:published_course, name: "Test Class", start_at: 1.day.from_now, channel: channel)
end

Then /^they should see this course in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Test Class")
  page.should have_content(channel_name)
end

Then /^they should not see this course$/ do
  page.should_not have_content("Test Class")
end

Then /^they should produce a copy of this course$/ do
  page.should have_content("Copy of Test Class")
  page.should have_content("Test Class")
  Course.find_all_by_name("Test Class").count.should == 2
end

Then /^this course should be trashed$/ do
  course = Course.find_by_name("Test Class")
  page.should have_content("Course #{course.id} trashed!")
  expect(course.visible).to be false
end

Given /^the "(.*?)" channel has a teacher percentage of "(.*?)" percent$/ do |channel_name, teacher_percentage|
  channel = Channel.find_by_name(channel_name)
  channel.teacher_percentage = teacher_percentage.to_d/100.0
  channel.save
end

Given /^the "(.*?)" channel has a channel percentage of "(.*?)" percent$/ do |channel_name, channel_percentage|
  channel = Channel.find_by_name(channel_name)
  channel.channel_rate_override = channel_percentage.to_d/100.0
  channel.save
end

When /^they fill in a teacher fee of "(.*?)"$/ do |teacher_cost|
  fill_in 'course_teacher_cost', with: teacher_cost
end

Then /^they should see an advertised price of "(.*?)"$/ do |price|
  page.execute_script("$('#course_teacher_cost').change()")
  sleep(1)
  find_field('Advertised price').value.should eq price
end

Given /^this course has one paid booking by a chalkler named "(.*?)"$/ do |name|
  course = Course.find_by_name("Test Class")
  course.update_attributes(:status => "Published", :cost => 10)
  chalkler = FactoryGirl.create(:chalkler, name: name)
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, paid: false, status: 'yes', cost_override: 20)
end

When /^they view this unpublished course$/ do
  click_link "Courses"
  click_link "Unpublished"
  click_link "View"
end

When /^they view this course$/ do
  click_link "Courses"
  click_link "View"
end

Then /^they should see a paid booking by "(.*?)"$/ do |name|
  page.should have_content(name)
  page.should have_content("yes")
end

Then /^this booking should be paid$/ do
  course = Course.find_by_name("Test Class")
  booking = course.bookings.first
end

Given(/^there is an unreviewed course with no details in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name(name)
  course = FactoryGirl.create(:course, name: "Test Class", status: "Unreviewed", channel: channel)
end

When(/^they fill in the courses comments with "(.*?)"$/) do |comments|
  fill_in 'active_admin_comment_body', with: comments
  click_button 'Add Comment'
end

Given(/^"(.*?)" is teaching a course$/) do |name|
  teacher = Chalkler.find_by_name name
  course = FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, channel: teacher.channels.first)
end

Given(/^the chalkler "(.*?)" has no email$/) do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.update_attribute(:email, nil)
end

Given(/^there is a course with no date in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler)
  course = FactoryGirl.create(:course_without_lessons, name: "Test class", teacher_id: teacher.id, do_during_class: "Nothing much", teacher_cost: 10, venue_cost: 10, channel: channel)
end

Given(/^there is a course with no what we will do text in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler)
  lesson = FactoryGirl.create(:lesson, start_at: 2.from_now.ago, duration: 1.5)
  course = FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, lessons: [lesson], do_during_class: nil, teacher_cost: 10, venue_cost: 10, channel: channel)
end

Given(/^there is a course with no teacher cost in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler)
  lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1.5)
  course = FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, lessons: [lesson], do_during_class: "Nothing much", teacher_cost: nil, venue_cost: 10, channel: channel)
end

Given(/^there is a course with no venue cost in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler)
  lesson = FactoryGirl.create(:lesson, start_at: 2.from_now.ago, duration: 1.5)
  course = FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, lessons: [lesson], do_during_class: "Nothing much", teacher_cost: 10, venue_cost: nil, channel: channel)
end

Given(/^there is a course in the "(.*?)" channel with RSVP numbers below the minimum number of attendees$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler, name: "Teacher")
  chalkler = FactoryGirl.create(:channel, name: "Chalkler")
  lesson = FactoryGirl.create(:lesson, start_at: 2.from_now.ago, duration: 1.5)
  course = FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, lessons: [lesson], do_during_class: "Nothing much", teacher_cost: 10, venue_cost: 2, min_attendee: 10, channel: channel)
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, guests: 2, status: 'yes')
end

When(/^they attach an image to the course$/) do
  attach_file('course_course_upload_image', "#{Rails.root}/app/assets/images/chalkle_logo_strapline_stacked.png")
  click_button 'Update Course'
end

Then(/^this image should be saved$/) do
  course = Course.find_by_name "Test Class"
  File.exist?("#{Rails.root}/public/uploads/test/course/course_upload_image/#{course.id}/chalkle_logo_strapline_stacked.png")
end

When(/^they visit the "(.*?)" channel class listing$/) do |name|
  channel = Channel.find_by_name name
  visit channel_path(channel)
end

Then(/^they should see this image on the class listing$/) do
  expect(page).to have_xpath("//img[contains(@src, 'chalkle_logo_strapline_stacked.png')]")
  FileUtils.remove_dir("#{Rails.root}/public/uploads/test", :force => true)
end
