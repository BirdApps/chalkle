Given /^I am logged in as a registered chalkler$/ do
  @chalkler = Chalkler.create(email: 'test@chalkle.com', password: 'password')
  visit '/chalklers/sign_in'
  fill_in 'chalkler_email', :with => 'test@chalkle.com'
  fill_in 'chalkler_password', :with => 'password'
  click_button 'Sign in'
end

Then /^I should see the email settings form$/ do
  page.should have_content("Set Your Email Preferences")
end

When /^I click on the button "(.*?)"$/ do |name|
  click_button name
end

Then /^I should see the email settings confirmation message$/ do
  page.should have_content("Your preferences have been saved")
end

When /^I type in my email as "(.*?)"$/ do |address|
  fill_in "chalkler_preferences_email", :with => address
end

Then /^my email should be "(.*?)"$/ do |address|
  @chalkler.reload
  @chalkler.email.should == address
end

Given /^my registered email is "(.*?)"$/ do |address|
  @chalkler.email = address
  @chalkler.save
end

Then /^the email "(.*?)" should be displayed$/ do |address|
  find_field('chalkler_preferences_email').value.should eq address
end

And /^I select "(.*?)" as my email frequency$/ do |frequency|
  page.select(frequency, :from => "chalkler_preferences_email_frequency")
end

Then /^my email frequency should be "(.*?)"$/ do |frequency|
  @chalkler.reload
  @chalkler.email_frequency.should == frequency
end

Given /^I had selected "(.*?)" as my email frequency$/ do |frequency|
  @chalkler.email_frequency = frequency
  @chalkler.save
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
