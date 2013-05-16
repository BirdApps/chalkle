# encoding: utf-8

When /^a new chalkler goes to the sign up page$/ do
  visit root_url
  click_link 'Join chalkle°'
end

When /^they enter their details$/ do
  fill_in 'Name', with: 'Mary Sue'
  fill_in 'Email', with: 'mary@example.com'
  fill_in 'chalkler_password', with: 'password'
  fill_in 'Password confirmation', with: 'password'
  click_button 'Sign up'
end

Then /^a new chalkler will be created$/ do
  chalkler = Chalkler.find_by_name 'Mary Sue'
  chalkler.channels.should == [ Channel.find_by_name('Horowhenua') ]
  chalkler.email.should == 'mary@example.com'
end


Given /^"(.*?)" is a new Meetup user$/ do |name|
  OmniAuth.config.mock_auth[:meetup] = {
      :provider => 'meetup',
      :uid => 12345678,
      :info => {
        :email => ''
      },
      :extra => {
      :raw_info => {
        :name => name
        }
      }
    }
end

Given /^"(.*?)" is an existing Meetup user$/ do |name|
  FactoryGirl.create(:chalkler, uid: 12345678, provider: 'meetup', email: "#{name.downcase}@chalkle.com", name: name)
  OmniAuth.config.mock_auth[:meetup] = {
      :provider => 'meetup',
      :uid => 12345678,
      :info => {
        :email => 'different@chalkle.com'
      },
      :extra => {
      :raw_info => {
        :name => 'Different name'
        }
      }
    }
end

When /^they log in via Meetup$/ do
  visit root_path
  click_link 'Sign in with Meetup'
end

# Then /^a new chalkler "(.*?)" is created with details from Meetup$/ do |name|
  # Chalkler.find_by_name(name).should be_valid
# end

Then /^they should see the Submit Email form$/ do
  page.should have_content('Almost there!')
end

When /^they submit the Submit Email form$/ do
  fill_in 'Email', with: 'jill@chalkle.com'
  click_button 'Submit email'
end

Then /^they should see the Dashboard$/ do
  page.should have_content('Sign in successful.')
end

Then /^the chalkler "(.*?)" should be updated$/ do |name|
  pending
  chalkler = Chalkler.find_by_name name
  chalkler.email.should == 'different@chalkle.com'
  chalkler.name.should == 'Different Name'
end

Then /^the chalkler "(.*?)" has an updated email$/ do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.email.should == 'jill@chalkle.com'
end

Given /^the chalkler "(.*?)" doesn't belong to a channel$/ do |name|
  chalkler = Chalkler.find_by_name name
  chalkler.channel_ids = []
end

Then /^they will be redirected to an error page$/ do
  page.should have_content('Oops!')
end
