When /^they visit the Email Settings page$/ do
  visit '/chalklers/preferences'
  page.has_content? "Set Your Email Preferences"
end

When /^they enter a new email address$/ do
  fill_in 'chalkler_preferences_email', with: 'new@chalkle.com'
  click_button 'Save Email Preferences'
end

Then /^the chalkler "(.*?)" should have a new email address$/ do |name|
  Chalkler.find_by_name(name).email.should == 'new@chalkle.com'
end

Then /^the email "(.*?)" should be displayed$/ do |address|
  find_field('chalkler_preferences_email').value.should == address
end

When /^they change their email frequency to "(.*?)"$/ do |frequency|
  page.has_content? "Set Your Email Preferences"
  select frequency, from: 'chalkler_preferences[email_frequency]'
end

Then /^the chalkler "(.*?)" should have a "(.*?)" email frequency$/ do |name, frequency|
  Chalkler.find_by_name(name).email_frequency.should == frequency
end

Then /^the email frequency "(.*?)" should be displayed$/ do |frequency|
  find_field('chalkler_preferences_email_frequency').value.should eq frequency
end

Given /^"(.*?)" and "(.*?)" are email categories$/ do |category1, category2|
  Category.create(name: category1)
  Category.create(name: category2)
end

When /^I select "(.*?)" and "(.*?)" as my email categories$/ do |category1, category2|
  page.check(category1)
  page.check(category2)
end

Then /^my email categories should be "(.*?)" and "(.*?)"$/ do |category1, category2|
  @chalkler.reload
  @chalkler.email_categories.should == [Category.find_by_name(category1).id, Category.find_by_name(category2).id]
end

Given /^I had set my email categories to "(.*?)" and "(.*?)"$/ do |category1, category2|
  @chalkler.email_categories = [Category.find_by_name(category1).id, Category.find_by_name(category2).id]
  @chalkler.save
end

Then /^the email categories "(.*?)" and "(.*?)" should be checked$/ do |category1, category2|
  find("#chalkler_preferences_email_categories_#{Category.find_by_name(category1).id}").should be_checked
  find("#chalkler_preferences_email_categories_#{Category.find_by_name(category2).id}").should be_checked
end

Given /^"(.*?)" is an email stream$/ do |stream1|
  Stream.create(name: stream1)
end

When /^I select "(.*?)" as my email stream$/ do |stream1|
  page.check(stream1)
end

Then /^my stream should be "(.*?)"$/ do |stream1|
  @chalkler.reload
  @chalkler.email_streams.should == [Stream.find_by_name(stream1).id]
end

Given /^I had set my stream to "(.*?)"$/ do |stream1|
  @chalkler.email_streams = [Stream.find_by_name(stream1).id]
  @chalkler.save
end

Then /^the email stream "(.*?)" should be checked$/ do |stream1|
  find("#chalkler_preferences_email_streams_#{Stream.find_by_name(stream1).id}").should be_checked
end
