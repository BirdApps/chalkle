Given /^A ([^"]*) meetup user$/ do |user_existence|
  if user_existence == "new"
    nil
  elsif user_existence == "existing"
    Chalkler.create(uid: 'abcde', provider: "meetup", email: 'different-test@xxxx.com', password: 'password', password_confirmation: 'password', name: "Test User2")
    OmniAuth.config.mock_auth[:meetup] = {
        :provider =>'meetup',
        :uid => 'abcde',
        :info => {
          :email => "different-test@xxxx.com"
        },
        :extra => {
        :raw_info => {
          :name => 'Test User2'
          }
        }
    }
  end
end

Then /^I should have a ([^"]*) Chalkle user with details from meetup$/ do |user_existence|
  if user_existence == "new"
    chalkler = Chalkler.find_by_uid("1234") 
    chalkler.sign_in_count.should == 1
    chalkler.name.should == "Test User"
  elsif user_existence == "existing"
    chalkler = Chalkler.find_by_email("different-test@xxxx.com") 
    chalkler.name.should == "Test User2"
    chalkler.sign_in_count.should == 2
  end
end
