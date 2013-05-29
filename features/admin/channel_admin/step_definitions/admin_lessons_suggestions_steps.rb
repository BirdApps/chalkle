Given /^there is a lesson suggestion with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  lesson_suggestion = FactoryGirl.create(:lesson_suggestion, name: "Test Suggestion", join_channels: [channel.id])
end

Then /^they should see this lesson suggestion in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Test Suggestion")
  page.should have_content(channel_name)
end
