Given /^there is a deleted lesson with no details in the "(.*?)" channel$/ do |name|
  channel = Channel.find_by_name(name)
  lesson = FactoryGirl.create(:lesson, name: "Test Class", visible: false, channel: channel)
end

Then /^they should see this lesson in the trash list$/ do
  lesson = Lesson.find_by_name("Test Class")
  page.should have_content("Test Class")
  page.should have_content(lesson.id.to_s)
end

Then /^this lesson should be undeleted$/ do
  lesson = Lesson.find_by_name("Test Class")
  lesson.visible.should be_true
end
