Given /^there is an active channel called "(.*?)"$/ do |channel_name|
  FactoryGirl.create(:channel, name: channel_name, visible: true)
end

Then /^they should not see the performance panel of "(.*?)"$/ do |channel_name|
  page.should_not have_content(channel_name)
end


