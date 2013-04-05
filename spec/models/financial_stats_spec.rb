require 'spec_helper'

describe "Financial_stats" do
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

  describe "Calculations" do

    before do
      @channel = FactoryGirl.create(:channel)
      @chalkler = FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5)
      (1..5).each do |i|
        lesson = FactoryGirl.create(:lesson, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, start_at: 2.days.ago, status: "Published", max_attendee: 10)
        lesson.channels << @channel
        booking = FactoryGirl.create(:booking, lesson_id: lesson.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: false)
        end
      end
      @financial_stats = @channel.financial_stats(6.days.ago, 7.days)
    end

    it "should calculate turnover" do
      @financial_stats.turnover.should == 150        
    end

    it "calculates total cost from lessons" do
      @financial_stats.cost.should == 125  
    end
 
  end
end
