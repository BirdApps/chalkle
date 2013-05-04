# encoding: UTF-8
When /^they enter new class suggestion details$/ do
  fill_in 'lesson_suggestion_name', with: 'new class suggestion'
  select 'Science', from: 'lesson_suggestion_category_id'
  fill_in 'lesson_suggestion_description', with: 'I suggest learning new stuff'
  click_button 'Suggest class'
end

When /^they enter new class suggestion details with channel$/ do
  fill_in 'lesson_suggestion_name', with: 'new class suggestion'
  fill_in 'lesson_suggestion_description', with: 'I suggest learning new stuff'
  select 'Science', from: 'lesson_suggestion_category_id'
  check 'Whanau'
  click_button 'Suggest class'
end

Then /^they should see the new class suggestion confirmation message$/ do
  page.should have_content('suggestion')
end
