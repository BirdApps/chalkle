Given /^there is an unreviewed lesson in the "(.*?)" channel$/ do |channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  lesson = FactoryGirl.create(:lesson, name: "Test Class", status: "Unreviewed")
  lesson.channels << channel
end

Then /^they should see this lesson under the Unreviewed panel$/ do
  page.should have_content("Test Class")
  page.should have_content("Unreviewed classes")
end
