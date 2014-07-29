Given(/^the chalkler "(.*?)" has booked a class$/) do |name|

  lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1)
  course = FactoryGirl.create(:course, cost: 10, lessons: [lesson], name: 'Cool class!', channel: FactoryGirl.create(:channel))
  chalkler = Chalkler.find_by_name name
  FactoryGirl.create(:booking, chalkler: chalkler, course: course, payment_method: 'cash')
end

When(/^they visit the bookings page$/) do
  visit bookings_path
end

Then(/^the unpaid booking should be displayed$/) do
  page.should have_content('Payment required')
  within(:css, '.payment-required-list') do
    page.should have_content('Cool class!')
  end
end

Given(/^the chalkler "(.*?)" has paid their booking$/) do |name|
  chalkler = Chalkler.find_by_name name
  booking = Booking.find_by_chalkler_id chalkler.id
  booking.update_attribute :paid, true
end

Then(/^the paid booking should be displayed$/) do
  page.should have_content('Confirmed classes')
  within(:css, '.confirmed-list') do
    page.should have_content('Cool class!')
  end
end

Given(/^the chalkler "(.*?)" has booked a free class$/) do |name|
  chalkler = Chalkler.find_by_name name
  lesson = FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 1)
  course = FactoryGirl.create(:course, cost: 0, name: 'Free class', lessons: [lesson])
  booking = FactoryGirl.create(:booking, chalkler: chalkler, course: course)
end

Then(/^the free booking will be displayed under "Confirmed classes"$/) do
  page.should have_content('Confirmed classes')
  within(:css, '.confirmed-list') do
    page.should have_content('Free class')
  end
end

Given(/^the chalkler "(.*?)" has been to a class already$/) do |name|
  course = Course.find_by_name 'Cool class!'
  #course.update_attribute :start_at, 3.days.ago
  course.start_at=3.days.ago
  Booking.find_by_course_id(course.id).update_attribute(:paid, true)
end

Then(/^their booking should not be displayed$/) do
  page.should have_no_content('Cool class!')
end

Given(/^the chalkler "(.*?)" has cancelled their booking$/) do |name|
  chalkler = Chalkler.find_by_name name
  booking = Booking.find_by_chalkler_id chalkler.id
  booking.update_attribute :status, status
end

Given(/^the chalkler "(.*?)" has paid their booking for a class next week$/) do |name|
  chalkler = Chalkler.find_by_name name
  booking = Booking.find_by_chalkler_id chalkler.id
  course = Course.find(booking.course_id)
  booking.update_attribute :paid, true
  course.update_attribute :start_at, 7.days.from_now
end

Then(/^they their booking should be editable$/) do
  page.should have_content 'Edit'
end

When(/^they click the "Edit" link$/) do
  click_link 'Edit'
end

Then(/^they should see the Edit Booking form$/) do
  page.should have_content 'Edit Booking'
end

When(/^they edit their booking$/) do
  page.select 'Just me', from: 'Attendees'
  click_button 'Confirm booking'
end

Then(/^their booking should be updated$/) do
  chalkler = Chalkler.find_by_name 'Said'
  booking = Booking.find_by_chalkler_id chalkler
  booking.guests.should == 0
end

Then(/^they should not see the "(.*?)" link$/) do |arg1|
  page.should_not have_content 'Edit'
end

When(/^they manually try to edit a paid booking$/) do
  chalkler = Chalkler.find_by_name 'Said'
  booking = Booking.find_by_chalkler_id chalkler
  visit edit_booking_path booking
end

Then(/^they should be redirected back to the single booking page$/) do
  page.should have_content 'You cannot edit a paid booking'
end
