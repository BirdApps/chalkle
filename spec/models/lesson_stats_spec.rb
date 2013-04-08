require 'spec_helper'

describe "Chalkler_stats" do

  describe "Activity statistics" do
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
    end

    it "calculates number of classes ran" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.lessons_ran.should == 5
    end

    it "calculates total attendee" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.attendee.should == 15
    end

    it "calculates fill fraction" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.fill_fraction.should == 30
    end

    it "calculates number of new classes ran" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 50.days.ago)
      lesson2.channels << @channel
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.new_lessons_ran.should == 4
      lesson2.destroy  
    end

    it "calculates number of paid classes" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 2.days.ago, cost: 0)
      lesson2.channels << @channel
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.paid_lessons.should == 5
    end
  
  end
end
