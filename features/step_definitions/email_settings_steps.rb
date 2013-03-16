Given /^I am logged in as a registered chalkler$/ do
  @chalkler = Chalkler.create(email: "test@chalkle.com", password: 'password')
  visit '/chalklers/sign_in'
  fill_in "chalkler_email", :with => "test@chalkle.com"
  fill_in "chalkler_password", :with => "password"
  click_button "Sign in"
end

Then /^I should see the email setting form$/ do
  page.should have_content("Set Your Email Preferences")
end

When /^I click on the button "(.*?)"$/ do |name|
  click_button "Save Email Preferences"
end

Then /^I should see the confirmation message$/ do
  page.should have_content("Your preferences have been saved")
end

When /^I type in my email as "(.*?)"$/ do |address|
  @email = address
  fill_in "chalkler_preferences_email", :with => address
end

Then /^my email should be saved$/ do
  @chalkler.reload
  @chalkler.email.should == @email
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

Given /^"(.*?)" and "(.*?)" are email categories$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I select "(.*?)" as my email category$/ do |name|
  page.select(name)
end

Then /^my email category should be saved$/ do
  
end

Given /^I had set my category to "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the email category "(.*?)" should be checked$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"(.*?)" is an email stream$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I select "(.*?)" as my email stream$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^my stream should be saved$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I had set my stream to "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the email stream "(.*?)" should be checked$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^there is an unreconciled payment with no details$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see this payment$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see this lesson$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see this channel$/ do
  pending # express the regexp above with the code you wish you had
end
