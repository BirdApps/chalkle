Given /^there is a course suggestion with no details in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  course_suggestion = FactoryGirl.create(:course_suggestion, name: "Test Suggestion", join_channels: [channel.id])
end

Then /^they should see this course suggestion in the "(.*?)" channel$/ do |channel_name|
  page.should have_content("Test Suggestion")
end
