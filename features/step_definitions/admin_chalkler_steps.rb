When /^they visit the Chalklers index page$/ do
  visit '/admin/chalklers'
end

When /^they visit the New Chalkler form$/ do
  visit '/admin/chalklers/new'
end

Then /^they should see channel checkboxes$/ do
  page.should have_content 'Wellington'
  page.should have_content 'Whanau'
end

Then /^they cannot see channel checkboxes$/ do
  page.should have_no_content 'Wellington'
end

When /^they create a chalkler with two channels$/ do
  fill_in 'chalkler_name', with: 'Jill'
  page.check 'Whanau'
  page.check 'Wellington'
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created with two channels$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  chalkler.channels includes(Channel.find_by_name 'Wellington')
  chalkler.channels includes(Channel.find_by_name 'Whanau')
end

When /^they create a chalkler$/ do
  admin_user = AdminUser.find_by_name 'John'
  fill_in 'chalkler_name', with: 'Jill'
  click_button 'Create Chalkler'
end

Then /^a new chalkler is created with one channel$/ do
  chalkler = Chalkler.find_by_name 'Jill'
  chalkler.channels includes(Channel.find_by_name 'Wellington')
end

When /^they create a chalkler without a channel$/ do
  fill_in 'chalkler_name', with: 'Jill'
  click_button 'Create Chalkler'
end

Then /^they should see an error message$/ do
  page.should have_content "Chalkler must belong to a channel"
end
