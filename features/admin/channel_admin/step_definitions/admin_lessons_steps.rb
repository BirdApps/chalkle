Given /^there is a lesson with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  Lesson.where(:name => "Test Class").destroy_all
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

Then /^they should produce a copy of this lesson$/ do
  page.should have_content("Copy of Test Class")
  page.should have_content("Test Class")
  Lesson.find_all_by_name("Test Class").count.should == 2
end

Then /^this lesson should be deleted$/ do
  lesson = Lesson.find_by_name("Test Class")
  page.should have_content("Lesson #{lesson.id} deleted!")
  lesson.visible.should be_false
end

Given /^the "(.*?)" channel has a teacher percentage of "(.*?)" percent$/ do |channel_name, teacher_percentage|
  channel = Channel.find_by_name(channel_name)
  channel.teacher_percentage = teacher_percentage.to_d/100.0
  channel.save
end

Given /^the "(.*?)" channel has a channel percentage of "(.*?)" percent$/ do |channel_name, channel_percentage|
  channel = Channel.find_by_name(channel_name)
  channel.channel_percentage = channel_percentage.to_d/100.0
  channel.save
end

When /^they fill in a teacher fee of "(.*?)"$/ do |teacher_cost|
  fill_in 'lesson_teacher_cost', with: teacher_cost
end

Then /^they should see an advertised price of "(.*?)"$/ do |price|
  page.execute_script("$('lesson_teacher_cost').keyup()")
  find_field('Advertised price').value.should eq price
end

