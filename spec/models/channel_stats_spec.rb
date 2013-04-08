require 'spec_helper'

describe "Channel_stats" do
  let(:start) { 3.months.ago.to_date }
  let(:period) { 7.days }
  let(:channel) { FactoryGirl.create(:channel) }

  let(:financial_stats) { channel.financial_stats(start, period) }

  describe "initialize" do
  	it "assign the correct current start date" do
  	  financial_stats.start.should == start
  	end

    it "assign the correct period" do
      financial_stats.period.should == period
    end

    it "assign the correct channel_id" do
      financial_stats.channel.should == channel
    end
  end

  describe "validation" do
    it "does not allow start date older than August 2012" do
      financial_stats.start = '2001-01-01'
      financial_stats.should_not be_valid
    end

    it "does not allow period less than 1 day" do
      financial_stats.period = 1.hour
      financial_stats.should_not be_valid
    end

    it "does not allow period less than 1 day" do
      financial_stats.channel = nil
      financial_stats.should_not be_valid
    end
  end

end
