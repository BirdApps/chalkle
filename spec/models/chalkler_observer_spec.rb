require 'spec_helper'

describe ChalklerObserver do

  let(:chalkler){ FactoryGirl.create(:chalkler, email: 'email@example.com') }

  describe "#send_welcome_mail" do
    it "sends welcome email"
    it "sends no email when chalkler has no email address"
  end

  describe "#create_channel_associations" do
    it "assigns a chalkler to channels"
  end

end
