require 'spec_helper'

describe "Financial_stats" do

  describe "Calculations" do

    let(:channel){ FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5) }
    let(:chalkler){ FactoryGirl.create(:chalkler) }
    let(:financial_stats){ channel.channel_stats(6.days.ago, 7.days).financial_stats }

    before(:each) do
      (1..5).each do |i|
        lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago)
        course = FactoryGirl.create(:course, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, chalkle_payment: 2*i, lessons: [lesson], max_attendee: 10, channel: channel, status: "Published")
        booking = FactoryGirl.create(:booking, course_id: course.id, guests: i-1, chalkler_id: chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: false)
        end
      end
      (6..8).each do |i|
        lesson = FactoryGirl.create(:lesson, start_at: 10.days.ago)
        course = FactoryGirl.create(:course, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, chalkle_payment: 2*i,  lessons: [lesson], status: "Published", max_attendee: 10, channel: channel)
        booking = FactoryGirl.create(:booking, course_id: course.id, guests: i-1, chalkler_id: chalkler.id, paid: true, status: "yes")
        if (i == 6)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: false)
        end
      end
    end

    it "should calculate turnover" do
      expect(financial_stats.turnover).to eq 150        
    end

    it "calculates total cost from courses" do
      expect((financial_stats.cost).round(2)).to eq (105 + 50).round(2)
    end

    it "calculates profit" do
      expect((financial_stats.profit).round(2)).to eq (-5/1.15).round(2)
    end

    it "should calculate turnover in previous time period" do
      expect(financial_stats.previous.turnover).to eq 210
    end

    it "should calculate percentage change in turnover" do
      expected = -(60.0/210.0*100.0)
      expect(financial_stats.percent_turnover.to_f).to be_within(0.00001).of(expected)
    end

    it "calculates total cost from previous period" do
      expect((financial_stats.previous.cost).round(2)).to eq (147 + 60).round(2)
    end

    it "calculates percentage change in cost" do
      expect((financial_stats.percent_cost).round(2)).to eq ((155.0/207.0 - 1.0)*100).round(2)
    end

    it "calculates profit from previous period" do
      expect((financial_stats.previous.profit).round(2)).to eq (3/1.15).round(2)
    end

    it "calculates percentage change in profit" do
      expect((financial_stats.percent_profit).round(2)).to eq (-(8.0/3.0*100.0).round(2))
    end
  end
end
