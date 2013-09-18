require 'spec_helper'

describe "Financial_stats" do

  describe "Calculations" do

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
      (6..8).each do |i|
        lesson = FactoryGirl.create(:lesson, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, chalkle_payment: 2*i, start_at: 10.days.ago, status: "Published", max_attendee: 10)
        lesson.channels << @channel
        booking = FactoryGirl.create(:booking, lesson_id: lesson.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 6)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: false)
        end
      end
      @financial_stats = @channel.channel_stats(6.days.ago, 7.days).financial_stats
    end

    it "should calculate turnover" do
      @financial_stats.turnover.should == 150        
    end

    it "calculates total cost from lessons" do
      (@financial_stats.cost).round(2).should == (105 + 50).round(2)
    end

    it "calculates profit" do
      (@financial_stats.profit).round(2).should == (-5/1.15).round(2)
    end

    it "should calculate turnover in previous time period" do
      @financial_stats.previous.turnover.should == 210
    end

    it "should calculate percentage change in turnover" do
      expected = -(60.0/210.0*100.0)
      @financial_stats.percent_turnover.to_f.should be_within(0.00001).of(expected)
    end

    it "calculates total cost from previous period" do
      (@financial_stats.previous.cost).round(2).should == (147 + 60).round(2)
    end

    it "calculates percentage change in cost" do
      (@financial_stats.percent_cost).round(2).should == ((155.0/207.0 - 1.0)*100).round(2)
    end

    it "calculates profit from previous period" do
      (@financial_stats.previous.profit).round(2).should == (3/1.15).round(2)
    end

    it "calculates percentage change in profit" do
      (@financial_stats.percent_profit).round(2).should == -(8.0/3.0*100.0).round(2)
    end
  end
end
