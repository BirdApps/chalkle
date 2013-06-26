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

    it "assign the correct end date" do
      channel_stats.instance_eval{ end_time }.should == start + period
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

  describe "calculation of percentage changes" do
    it "returns percentage change given initial and final values" do
      channel_stats.instance_eval{ percentage_change(2,5) }.should == (3.0/2.0*100)
    end

    it "returns nil if initial value is 0" do
      channel_stats.instance_eval{ percentage_change(0,5) }.should == nil
    end
  end

  describe "creation of stats objects" do
    before do
      @channel = FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5)
      @chalkler = FactoryGirl.create(:chalkler)
      (1..5).each do |i|
        lesson = FactoryGirl.create(:lesson, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, chalkle_payment: 2*i, start_at: 2.days.ago, status: "Published", max_attendee: 10)
        lesson.channels << @channel
        booking = FactoryGirl.create(:booking, lesson_id: lesson.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: false)
        end
      end
      @channel_stats = @channel.channel_stats(7.days.ago, 7.days)
    end

    it "create a financial stats object" do
      @channel_stats.financial_stats.turnover.should == 150
    end

    it "create a lesson stats object" do
      @channel_stats.lesson_stats.lessons_announced.should == 5
    end

    it "create a chalkler stats object" do
      @channel_stats.chalkler_stats.attendee.should == 15
    end
  end

end
