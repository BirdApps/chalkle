Given /^there is a lesson with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  lesson = FactoryGirl.create(:lesson, name: "Test Class")
  lesson.channels << channel
end

Then /^they should see this lesson in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Test Class")
  page.should have_content(channel_name)
end

Then /^they should not see this lesson$/ do
  page.should_not have_content("Test Class")
end

Then /^they should see a copy of this lesson in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Copy of Test Class")
  page.should have_content("Test Class")
  channel = Channel.find_by_name(channel_name)
  Lesson.last.name.should == "Test Class"
  Lesson.last.channels.should == [channel]
end


