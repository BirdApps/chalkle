Given(/^there is a class "(.*?)" open to sign\-up$/) do |name|
  lesson = FactoryGirl.create(:lesson,
                              name: 'Test class',
                              status: 'Published',
                              start_at: 1.minute.from_now,
                              cost: 10,
                              visible: true,
                              max_attendee: 10)
  channel = Channel.find_by_name "Horowhenua"
  lesson.channels << channel
end

When(/^they visit the class listings$/) do
  channel = Channel.find_by_name "Horowhenua"
  visit channel_path(channel)
end

And(/^select the first class$/) do
  page.click_link "lesson_#{Lesson.last.id}"
end

When(/^they select the payment method "(.*?)"$/) do |method|
  page.select(method, :from => 'booking_payment_method')
end

When(/^they select the number of attendees "(.*?)"$/) do |guests|
  page.select(guests, :from => 'booking_guests')
end

When(/^they agree with the terms and conditions$/) do
  page.check('booking_terms_and_conditions')
end

Then(/^they should see a summary of this booking$/) do
  page.should have_content('Booking: Test class')
  page.should have_content('How to pay')
end

Given(/^the chalkler has cancelled an unpaid booking$/) do
  lesson = Lesson.find_by_status "Published"
  chalkler = Chalkler.find_by_name "Said"
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, status: "no", paid: false)
end

Given(/^the chalkler "(.*?)" has cancelled a booking$/) do |name|
  lesson = Lesson.find_by_name 'Test class'
  chalkler = Chalkler.find_by_name name
  FactoryGirl.create(:booking, chalkler_id: chalkler.id, lesson_id: lesson.id, status: 'no')
end

When(/^they visit an open class$/) do
  channel = Channel.find_by_name 'Horowhenua'
  lesson = Lesson.find_by_status 'Published'
  visit channel_lesson_path channel, lesson
end

When(/^they fill out the booking form$/) do
  page.select 'Bank Transfer', :from => 'booking_payment_method'
  page.select('Just me', :from => 'booking_guests')
  page.check('booking_terms_and_conditions')
  click_button 'Confirm booking'
end
