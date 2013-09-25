Given /^there is an unreviewed lesson in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "Unreviewed", cost: 5)
  lesson.channels << channel
end

Then /^they should see this lesson under the "(.*?)" panel$/ do |panel_name|
  page.should have_content("Test Class")
  page.should have_content("$5.00")
  page.should have_content(panel_name)
end

Given /^there is a lesson in the "(.*?)" channel being processed$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "Processing", cost: 5)
  lesson.channels << channel
end

Given /^there is an approved lesson in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "Approved", cost: 5)
  lesson.channels << channel
end

Given /^there is an on-hold lesson in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "On-hold", cost: 5)
  lesson.channels << channel
end

Given /^there is lesson in the "(.*?)" channel coming up this week$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "Published", start_at: 2.days.from_now, cost: 5)
  lesson.channels << channel
end

Then(/^they should see an "(.*?)" link$/) do |name|
  page.should have_link(name)
end

Given /^there is lesson in the "(.*?)" channel coming up this week with minimum attendee of "(.*?)"$/ do |channel_name, min_attendee|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  teacher = FactoryGirl.create(:chalkler, name: "Teacher")
  lesson = FactoryGirl.create(:lesson, name: "Test Class", teacher_id: teacher.id, start_at: 2.days.from_now, do_during_class: "Nothing much", teacher_cost: nil, venue_cost: 10, status: "Published", cost: 10, venue: "Town Hall", min_attendee: min_attendee)
  lesson.channels << channel
end

Given(/^the number of RSVPs is "(.*?)"$/) do |bookings_count|
	lesson = Lesson.find_by_name("Test Class")
	chalkler = FactoryGirl.create(:chalkler, name: "Test chalkler")
	chalkler.channels  = lesson.channels
	FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, guests: bookings_count.to_i-1)
end

Given(/^there is lesson in the "(.*?)" channel coming up this week with no teacher cost$/) do |name|
  channel = Channel.find_by_name(name)
  teacher = FactoryGirl.create(:chalkler, name: "Teacher")
  chalkler = FactoryGirl.create(:channel, name: "Student")
  lesson = FactoryGirl.create(:lesson, name: "Test class", teacher_id: teacher.id, start_at: 2.days.from_now, do_during_class: "Nothing much", teacher_cost: nil, venue_cost: 10, status: "Published", cost: 10, venue: "Town Hall")
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, guests: 10, status: 'yes')
  lesson.channels << channel
end


