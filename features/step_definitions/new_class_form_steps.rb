# encoding: UTF-8
When /^they enter new class details$/ do
  fill_in 'teaching_title', with: 'new class'
  fill_in 'teaching_do_during_class', with: 'learning new stuff'
  fill_in 'teaching_learning_outcomes', with: 'the new stuff'
  select 'Science', from: 'teaching_category_primary_id'
  click_button 'Submit my class'
end

When /^they enter new class details with channel$/ do
  fill_in 'teaching_title', with: 'new class'
  fill_in 'teaching_do_during_class', with: 'learning new stuff'
  fill_in 'teaching_learning_outcomes', with: 'the new stuff'
  select 'Science', from: 'teaching_category_primary_id'
  select 'Whanau', from: 'teaching_channel_id'
  click_button 'Submit my class'
end

Then /^they should see the new class confirmation message$/ do
  page.should have_content('Class submitted!')
end

Then /^the "(.*?)" channel email link will be displayed$/ do |channel|
  channel = Channel.find_by_name channel
  page.should have_link(channel.email)
end
