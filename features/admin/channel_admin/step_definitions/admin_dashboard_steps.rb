Given /^there is an unreviewed course in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first || Channel.create({name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"}, :as => :admin)
  Course.where(:name => "Test Class").destroy_all
  course = FactoryGirl.create(:course, name: "Test Class", status: "Unreviewed", cost: 5, channel: channel)
end

Then /^they should see this course under the "(.*?)" panel$/ do |panel_name|
  page.should have_content("Test Class")
  page.should have_content("$5.00")
  page.should have_content(panel_name)
end

Given /^there is a course in the "(.*?)" channel being processed$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Course.where(:name => "Test Class").destroy_all
  course = FactoryGirl.create(:course, name: "Test Class", status: "Processing", cost: 5, channel: channel)
end

Given /^there is an approved course in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Course.where(:name => "Test Class").destroy_all
  course = FactoryGirl.create(:course, name: "Test Class", status: "Approved", cost: 5, channel: channel)
end

Given /^there is an on-hold course in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Course.where(:name => "Test Class").destroy_all
  course = FactoryGirl.create(:course, name: "Test Class", status: "On-hold", cost: 5, channel: channel)
end

Given /^there is course in the "(.*?)" channel coming up this week$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)

  Course.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1)
  course = FactoryGirl.create(:course, name: "Test Class", status: "Published", lessons: [lesson], cost: 5, channel: channel)
end

Then(/^they should see an "(.*?)" link$/) do |name|
  page.should have_link(name)
end

Given /^there is course in the "(.*?)" channel coming up this week with minimum attendee of "(.*?)"$/ do |channel_name, min_attendee|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Course.where(:name => "Test Class").destroy_all
  teacher = FactoryGirl.create(:chalkler, name: "Teacher")
  lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1)
  course = FactoryGirl.create(:course, name: "Test Class", teacher_id: teacher.id, lessons: [lesson], do_during_class: "Nothing much", teacher_cost: nil, venue_cost: 10, status: "Published", cost: 10, venue: "Town Hall", min_attendee: min_attendee, channel: channel)
end

Given(/^the number of RSVPs is "(.*?)"$/) do |bookings_count|
	course = Course.find_by_name("Test Class")
	chalkler = FactoryGirl.create(:chalkler, name: "Test chalkler")
	FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, guests: bookings_count.to_i-1)
end

Given(/^there is course in the "(.*?)" channel coming up this week with no teacher cost$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler, name: "Teacher")
  chalkler = FactoryGirl.create(:channel, name: "Student")
  lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1)
  course = FactoryGirl.create(:course, name: "Test class", teacher_id: teacher.id, lessons: [lesson], do_during_class: "Nothing much", teacher_cost: nil, venue_cost: 10, status: "Published", cost: 10, venue: "Town Hall", channel: channel)
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, guests: 10, status: 'yes')
end


