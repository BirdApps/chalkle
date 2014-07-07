Given /^there is a booking with no details$/ do
  course = FactoryGirl.create(:course, name: "Test Class")
  chalkler = FactoryGirl.create(:chalkler)
  FactoryGirl.create(:booking, course_id: course.id, chalkler_id: chalkler.id, payment_method: 'free', status: 'yes')
end

Then /^they should see this booking$/ do
  page.should have_content("Test Class")
end

Then /^this booking should be deleted$/ do
  course = Course.find_by_name("Test Class")
  booking = Booking.find_by_course_id(course.id)
  page.should have_content("Booking #{booking.id} deleted!")
  booking.visible.should be_false
end

Given /^there is a paid booking$/ do
  course = FactoryGirl.create(:course, name: "Test Class", cost: 10)
  chalkler = FactoryGirl.create(:chalkler)
  FactoryGirl.create(:booking, course_id: course.id, chalkler_id: chalkler.id, status: 'yes', payment_method: 'Cash', paid: true)
end

Given(/^there is a paid booking by the teacher of the class$/) do
  chalkler = FactoryGirl.create(:chalkler)
  course = FactoryGirl.create(:course, name: "Test Class", teacher_id: chalkler.id, cost: 0)
  FactoryGirl.create(:booking, course_id: course.id, chalkler_id: chalkler.id, status: 'yes')
end
