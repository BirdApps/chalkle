Then /^they should see their channel "(.*?)"$/ do |channel_name|
  page.should have_content(channel_name)
end

Then /^they should see the default channel percentage of the "(.*?)" channel$/ do |channel_name|
  channel = Channel.find_by_name(channel_name)
  page.should have_content((100*channel.channel_percentage).to_s)
end
