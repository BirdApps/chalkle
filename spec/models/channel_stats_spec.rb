require 'spec_helper'

describe "Channel_stats" do
  let(:start) { 3.months.ago.to_date }
  let(:period) { 7.days }
  let(:channel) { FactoryGirl.create(:channel) }

  let(:channel_stats) { channel.channel_stats(start, period) }

  describe "initialize" do
  	it "assign the correct current start date" do
  	  expect(channel_stats.start).to eq start
  	end

    it "assign the correct period" do
      expect(channel_stats.period).to eq period
    end

    it "assign the correct channel_id" do
      expect(channel_stats.channel).to eq channel
    end

    it "assign the correct end date" do
      expect(channel_stats.instance_eval{ end_time }).to eq start + period
    end
  end

  describe "validation" do
    it "does not allow start date older than August 2012" do
      channel_stats.start = '2001-01-01'
      expect(channel_stats).not_to be_valid
    end

    it "does not allow period less than 1 day" do
      channel_stats.period = 1.hour
      expect(channel_stats).not_to be_valid
    end

    it "does not allow period less than 1 day" do
      channel_stats.channel = nil
      expect(channel_stats).not_to be_valid
    end
  end

  describe "calculation of percentage changes" do
    it "returns percentage change given initial and final values" do
      expect(channel_stats.instance_eval{ percentage_change(2,5) }).to eq (3.0/2.0*100)
    end

    it "returns nil if initial value is 0" do
      expect(channel_stats.instance_eval{ percentage_change(0,5) }).to eq nil
    end
  end

  describe "creation of stats objects" do
    before do
      @channel = FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5)
      @chalkler = FactoryGirl.create(:chalkler)
      (1..5).each do |i|
        course = FactoryGirl.create(:course, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, chalkle_payment: 2*i, start_at: 2.days.ago, status: "Published", max_attendee: 10, channel: @channel)
        booking = FactoryGirl.create(:booking, course_id: course.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10, reconciled: true, cash_payment: false)
        end
      end
      @channel_stats = @channel.channel_stats(7.days.ago, 7.days)
    end

    it "create a financial stats object" do
      expect(@channel_stats.financial_stats.turnover).to eq 150
    end

    it "create a course stats object" do
      expect(@channel_stats.course_stats.courses_announced).to eq 5
    end

    it "create a chalkler stats object" do
      expect(@channel_stats.chalkler_stats.attendee).to eq 15
    end
  end

end
