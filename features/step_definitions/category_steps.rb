Given /^the "(.*?)" category exists$/ do |category|
  FactoryGirl.create(:category, name: category)
end
