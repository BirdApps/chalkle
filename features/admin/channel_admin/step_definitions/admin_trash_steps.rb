Given /^there is a deleted lesson with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  lesson.visible = false
  lesson.save
  lesson.channels << channel
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
