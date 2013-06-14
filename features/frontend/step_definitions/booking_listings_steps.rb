Given(/^the chalkler "(.*?)" has booked a class$/) do |name|
  lesson = FactoryGirl.create(:lesson, cost: 10, start_at: 3.days.from_now, name: 'Cool class!')
  chalkler = Chalkler.find_by_name name
  FactoryGirl.create(:booking, chalkler: chalkler, lesson: lesson)
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
  lesson = FactoryGirl.create(:lesson, cost: 0, name: 'Free class', start_at: 3.days.from_now)
  booking = FactoryGirl.create(:booking, chalkler: chalkler, lesson: lesson)
end

Then(/^the free booking will be displayed under "Confirmed classes"$/) do
  page.should have_content('Confirmed classes')
  within(:css, '.confirmed-list') do
    page.should have_content('Free class')
  end
end

Given(/^the chalkler "(.*?)" has been to a class already$/) do |name|
  lesson = Lesson.find_by_name 'Cool class!'
  lesson.update_attribute :start_at, 3.days.ago
  Booking.find_by_lesson_id(lesson.id).update_attribute(:paid, true)
end

Then(/^their booking should not be displayed$/) do
  page.should have_no_content('Cool class!')
end
