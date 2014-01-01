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
  FactoryGirl.create(:category, name: category1, primary: true)
  FactoryGirl.create(:category, name: category2, primary: true)
  visit current_path
end

When /^they select new email categories$/ do
  check 'business & finance'
  check 'food & drink'
  click_button 'Save Email Preferences'
end

Then /^the chalkler "(.*?)" should have new category settings$/ do |name|
  chalkler = Chalkler.find_by_name name
  cat1 = Category.find_by_name 'business & finance'
  cat2 = Category.find_by_name 'food & drink'
  [cat1.id, cat2.id].each{ |c| chalkler.email_categories.should include(c) }
end
