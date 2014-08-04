
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
  fill_in 'teaching_duration_hours', with: '5'
  fill_in 'teaching_duration_minutes', with: '30'
  click_button 'Submit my class'
end

Then /^they should see the new class confirmation message$/ do
  page.should have_content('Class submitted!')
end

Then /^the "(.*?)" channel email link will be displayed$/ do |channel|
  channel = Channel.find_by_name channel
  page.should have_content(channel.email)
end

And(/^the learn@chalkle email link will be displayed$/) do
  page.should have_content('learn@chalkle.com')
end

When /^they select the "(.*?)" channel$/ do |channel|
  select channel, from: 'teaching_channel_id'
end

And /^they enter a teacher cost$/ do
  fill_in 'teaching_teacher_cost', with: '20'
end

Then /^the advertised price for the "(.*?)" channel will be displayed$/ do |channel|
  page.execute_script("$('#teaching_teacher_cost').change()")
  sleep(1)
  find_field('teaching_cost').value.should == "25.0"
end
