

When(/^they follow the channel$/) do
  click_link 'FOLLOW'
end

Then(/^they should see the option to unfollow the channel$/) do
  page.should have_content("UNFOLLOW")
end

When(/^they unfollow the channel$/) do
  click_link 'UNFOLLOW'
end

Then(/^they should see the option to follow the channel$/) do
  page.should have_content("FOLLOW")
end