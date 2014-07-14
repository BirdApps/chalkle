Given /^there is a deleted course with no details in the "(.*?)" channel$/ do |name|
  channel = Channel.find_by_name(name)
  course = FactoryGirl.create(:course, name: "Test Class", visible: false, channel: channel)
end

Then /^they should see this course in the trash list$/ do
  course = Course.find_by_name("Test Class")
  page.should have_content("Test Class")
  page.should have_content(course.id.to_s)
end

Then /^this course should be undeleted$/ do
  course = Course.find_by_name("Test Class")
  expect(course.visible).to be true
end
