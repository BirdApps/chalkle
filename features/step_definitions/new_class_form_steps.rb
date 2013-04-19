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
  select 'Whanau', from: 'teaching_channel_select'
  click_button 'Submit my class'
end

Then /^they should see the new class confirmation message$/ do
  page.should have_content('Class submitted!')
end

Then /^the "(.*?)" channel email link will be displayed$/ do |channel|
  channel = Channel.find_by_name channel
  page.should have_link(channel.email)
end

When /^they enter a teacher cost$/ do 
  fill_in 'teaching_teacher_cost', with: '20'
end

Then /^the advertised price will be displayed$/ do
  find_field('teaching_teacher_cost').value.should eq '20'
end

