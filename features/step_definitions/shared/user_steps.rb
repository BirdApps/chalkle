Given /^"(.*?)" is a chalkler$/ do |name|
  chalkler = FactoryGirl.create(:chalkler, name: name, email: "#{name.downcase}@chalkle.com", password: 'password')
  chalkler.channels << FactoryGirl.create(:channel, name: 'Wellington')
end

Given /^the admin "(.*?)" belongs to the "(.*?)" channel$/ do |admin_name, channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com"], :as => :admin)
  admin_user = AdminUser.find_by_name admin_name
  admin_user.channels << channel
end

Given /^the chalkler "(.*?)" belongs to the "(.*?)" channel$/ do |chalkler_name, channel_name|
  channel = Channel.where(name: channel_name).first_or_create!([name: channel_name, url_name: channel_name.downcase, email: "#{channel_name.downcase}@chalkle.com", teacher_percentage: 0.01, channel_percentage: 0.01], :as => :admin)
  chalkler = Chalkler.find_by_name chalkler_name
  chalkler.channels << channel
end

Given /^the admin "(.*?)" has the "(.*?)" role$/ do |admin_name, role|
  admin_user = AdminUser.find_by_name admin_name
  admin_user.role = role
  admin_user.save
end
