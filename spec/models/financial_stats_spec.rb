require 'spec_helper'

describe "Financial_stats" do

  describe "Calculations" do

    before do
      @channel = FactoryGirl.create(:channel)
      @chalkler = FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5)
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
      @financial_stats = @channel.channel_stats(6.days.ago, 7.days).financial_stats
    end

    it "should calculate turnover" do
      @financial_stats.turnover.should == 150        
    end

    it "calculates total cost from lessons" do
      (@financial_stats.cost).round(2).should == (150 + 5).round(2)
    end

    it "calculates profit" do
      (@financial_stats.profit).round(2).should == (-5/1.15).round(2)
    end
 
  end
end
