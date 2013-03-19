require 'spec_helper'

describe "the signup process", :type => :feature do
  before :each do
    @chalkler = FactoryGirl.create(:chalkler)
    Chalkler.stub(:find_for_meetup_oauth).and_return(@chalkler)
  end

  it "signs me in via devise login" do
    visit '/chalklers/sign_in'
    within("#new_chalkler") do
      fill_in 'Email', :with => 'ben@hotmail.com'
      fill_in 'Password', :with => 'password'
    end
    click_button 'Sign in'
    page.should have_content 'Sign out'
    click_link 'Sign out'
  end


  it "signs me in via meetup login" do
    set_omniauth()
    visit '/chalklers/sign_in'
    click_link 'Sign in with Meetup'
    page.should have_content 'Sign out'
    page.should have_content 'Welcome'
  end
end
