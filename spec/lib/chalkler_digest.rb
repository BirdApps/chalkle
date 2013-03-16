require 'spec_helper'
require 'chalkler_digest'

describe ChalklerDigest do
  describe ".load_chalklers" do
    it "won't return a chalkler without an email address" do
      FactoryGirl.create(:chalkler, email: nil, email_frequency: 'weekly')
      ChalklerDigest.load_chalklers('weekly').should be_empty
    end

    it "won't returns a chalkler without correct frequency" do
      c = FactoryGirl.create(:chalkler, email: 'example@example.com', email_frequency: 'weekly')
      ChalklerDigest.load_chalklers('daily').should be_empty
    end

    it "will return a chalkler when email and correct email_frequency set" do
      c = FactoryGirl.create(:chalkler, email: 'example@example.com', email_frequency: 'weekly')
      ChalklerDigest.load_chalklers('weekly').count.should == 1
    end
  end
end
