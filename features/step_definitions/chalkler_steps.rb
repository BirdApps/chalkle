
And /^I click the "(.*?)" button$/ do |button|
  click_button button
end

Then /^I should see the new chalkler form$/ do
  page.should have_content("New Chalkler")
end

Given /^I am logged in with the "(.*?)" role with (\d+) channels$/ do |role, num_channels|
  @admin = AdminUser.create(email: "test@chalkle.com", password: 'password', role: role)
  @channel = []
  (0..(num_channels.to_i-1)).each do |i|
    @channel[i] = Channel.create(name: "Test Channel #{i}")
  end
  @admin.channels = @channel
  visit '/admin/login'
  fill_in "admin_user_email", :with => "test@chalkle.com"
  fill_in "admin_user_password", :with => "password"
  click_button "Login"
end

And /^I fill in the email of the chalkler$/ do
  fill_in "Email", :with => "test@gmail.com"
end

When /^I select channels "(.*?)" and "(.*?)"$/ do |name1, name2|
  page.check(name1)
  page.check(name2)
end

Then /^a new chalkler is created in channels "(.*?)" and "(.*?)"$/ do |name1, name2|
  @chalkler = Chalkler.find_by_email("test@gmail.com")
  @chalkler.should_not be_nil
  @chalkler.channels.should == [Channel.find_by_name(name1),Channel.find_by_name(name2)]
end


Then /^a new chalkler is created in my channel$/ do
  @chalkler = Chalkler.find_by_email("test@gmail.com")
  @chalkler.should_not be_nil
  @chalkler.channels.should == [@admin.channels.first]
end

