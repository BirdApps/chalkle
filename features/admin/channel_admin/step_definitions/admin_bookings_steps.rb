Given(/^there is a booking with no details in the "(.*?)" channel$/) do |name|
  channel = Channel.find_by_name name
  lesson = FactoryGirl.create(:lesson, name: "Test Class", channel: channel)
  chalkler = FactoryGirl.create(:chalkler)
  chalkler.channels << channel
  FactoryGirl.create(:booking, lesson_id: lesson.id, chalkler_id: chalkler.id, payment_method: 'free', status: 'yes')
end

Then(/^they should see this booking in the "(.*?)" channel$/) do |name|
  page.should have_content("Test Class")
end

