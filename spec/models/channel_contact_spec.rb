require "spec_helper"

describe ChannelContact do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:channel_contact) {
   FactoryGirl.create(:channel_contact) }

  describe "Channel Mailer" do

    it 'should send email' do 
      expect{ channel_contact }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

  end

end
