When /^they enter new email settings$/ do
  page.fill_in 'chalkler_preferences_email', with: 'new@chalkle.com'
  page.select 'Daily', from: 'chalkler_preferences_email_frequency'
  click_button 'Save Email Preferences'
end

Then /^the chalkler "(.*?)" should have new email settings$/ do |name|
  chalkler = Chalkler.find_by_name(name)
  chalkler.email.should == 'new@chalkle.com'
  chalkler.email_frequency.should == 'daily'
end

Given /^"(.*?)" and "(.*?)" are email categories$/ do |category1, category2|
  FactoryGirl.create(:category, name: category1)
  FactoryGirl.create(:category, name: category2)
  visit current_path
end

Given /^"(.*?)" is an email stream$/ do |stream|
  FactoryGirl.create(:stream, name: stream)
  visit current_path
end

When /^they select new email categories and streams$/ do
  check 'business & finance'
  check 'food & drink'
  check 'Royal Society Wellington Branch'
  click_button 'Save Email Preferences'
end

Then /^the chalkler "(.*?)" should have new category and stream settings$/ do |name|
  chalkler = Chalkler.find_by_name name
  cat1 = Category.find_by_name 'business & finance'
  cat2 = Category.find_by_name 'food & drink'
  stream = Stream.find_by_name 'Royal Society Wellington Branch'
  [cat1.id, cat2.id].each{ |c| chalkler.email_categories.should include(c) }
  chalkler.email_streams.should include(stream.id)
end
