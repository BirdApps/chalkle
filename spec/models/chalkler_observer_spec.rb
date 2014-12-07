require 'spec_helper'

describe ChalklerObserver do

  let(:chalkler){ FactoryGirl.create(:chalkler, email: 'email@example.com') }
  let(:unsaved_chalkler){ FactoryGirl.build(:chalkler) }
  before { ActiveRecord::Base.observers.enable :chalkler_observer }
  describe "#send_welcome_mail" do
    it 'should send welcome mailer on chalkler create' do
      expect{ unsaved_chalkler.save }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
  
  describe "sets a notification preference for new chalklers" do
    it 'should add notification preference to new chalklers' do 
      expect( chalkler.notification_preference ).not_to be_nil 
    end
  end

end
