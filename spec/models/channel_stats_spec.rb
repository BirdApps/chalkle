require 'spec_helper'

describe "Channel_stats" do
  let(:start) { 3.months.ago.to_date }
  let(:period) { 7.days }
  let(:channel) { FactoryGirl.create(:channel) }

  let(:channel_stats) { channel.channel_stats(start, period) }

  describe "initialize" do
  	it "assign the correct current start date" do
  	  channel_stats.start.should == start
  	end

    it "assign the correct period" do
      channel_stats.period.should == period
    end

    it "assign the correct channel_id" do
      channel_stats.channel.should == channel
    end
  end

  describe "validation" do
    it "does not allow start date older than August 2012" do
      channel_stats.start = '2001-01-01'
      channel_stats.should_not be_valid
    end

    it "does not allow period less than 1 day" do
      channel_stats.period = 1.hour
      channel_stats.should_not be_valid
    end

    it "does not allow period less than 1 day" do
      channel_stats.channel = nil
      channel_stats.should_not be_valid
    end
  end

end
