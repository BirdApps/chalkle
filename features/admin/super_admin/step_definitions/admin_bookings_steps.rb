Given /^there is a booking with no details$/ do
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  chalkler = FactoryGirl.create(:chalkler)
  FactoryGirl.create(:booking, lesson_id: lesson.id, chalkler_id: chalkler.id, payment_method: 'free', status: 'yes')
end

Then /^they should see this booking$/ do
  page.should have_content("Test Class")
end

Then /^this booking should be deleted$/ do
  booking = Booking.last
  page.should have_content("Booking #{booking.id} deleted!")
  booking.visible.should be_false
end
