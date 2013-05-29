Given /^there is a booking with no details$/ do
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  chalkler = FactoryGirl.create(:chalkler)
  FactoryGirl.create(:booking, lesson_id: lesson.id, chalkler_id: chalkler.id, payment_method: 'free', status: 'yes')
end

Then /^they should see this booking$/ do
  page.should have_content("Test Class")
end

Then /^this booking should be deleted$/ do
  lesson = Lesson.find_by_name("Test Class")
  booking = Booking.find_by_lesson_id(lesson.id)
  page.should have_content("Booking #{booking.id} deleted!")
  booking.visible.should be_false
end

Given /^there is a paid booking$/ do
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  chalkler = FactoryGirl.create(:chalkler)
  FactoryGirl.create(:booking, lesson_id: lesson.id, chalkler_id: chalkler.id, payment_method: 'free', status: 'yes', paid: true)
end
