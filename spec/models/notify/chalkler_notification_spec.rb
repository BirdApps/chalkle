require 'spec_helper'

describe Notify::ChalklerNotification  do
  let(:chalkler) { FactoryGirl.create :chalkler }

  describe '.welcome' do
    it "notifies chalkler" do
      chalkler.notifications = []
      expect { Notify.for(chalkler).welcome }.to change { chalkler.notifications.count }.by(1)
    end

    it "emails chalkler" do
      expect { Notify.for(chalkler).welcome }.to change { ActionMailer::Base.deliveries.select{ |mail| mail.to.include? chalkler.email }.count }.by(1)
    end
  end

end