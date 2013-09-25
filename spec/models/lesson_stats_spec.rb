require 'spec_helper'

describe "Chalkler_stats" do

  describe "Lesson activity statistics" do
    before do
      @chalkler = FactoryGirl.create(:chalkler)
      @channel = FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5)
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
      (6..8).each do |i|
        lesson = FactoryGirl.create(:lesson, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, start_at: 5.days.ago, status: "Published", max_attendee: 10)
        lesson.channels << @channel
        booking = FactoryGirl.create(:booking, lesson_id: lesson.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: false)
        end
      end
      lesson1 = FactoryGirl.create(:lesson, name: "Cancelled lesson 1", status: "Published", start_at: 2.days.ago, cost: 10)
      lesson1.channels << @channel
      lesson1.update_attributes({:visible => false}, :as => :admin)
      lesson2 = FactoryGirl.create(:lesson, name: "Cancelled lesson 2", status: "Published", start_at: 5.days.ago, cost: 10)
      lesson2.channels << @channel
      lesson2.update_attributes({:visible => false}, :as => :admin)
    end

    it "calculates number of lessons announced" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.lessons_announced.should == 6
    end

    it "calculates number of lessons announced in the previous time period" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.previous.lessons_announced.should == 4
    end

    it "calculates percentage change in lessons announced" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.percent_lessons_announced.should == 50.0
    end

    it "calculates number of classes ran" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.lessons_ran.should == 5
    end

    it "calculates number of classes ran in the previous time period" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.previous.lessons_ran.should == 3
    end

    it "calculates percentage change in number of classes ran" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.percent_lessons_ran.to_f.should be_within(0.00001).of(2.0/3.0*100.0)
    end

    it "calculates number of new classes ran" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 50.days.ago)
      lesson2.channels << @channel
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.new_lessons_ran.should == 4
      lesson2.destroy  
    end

    it "calculates number of cancelled classes" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.cancelled_lessons.should == 1
    end

    it "calculates number of cancelled classes in previous time period" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.previous.cancelled_lessons.should == 1 
    end

    it "calculates number of new cancelled classes" do
      lesson = FactoryGirl.create(:lesson, name: "Cancelled lesson 1", status: "Published", start_at: 10.days.ago, cost: 10)
      lesson.channels << @channel
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.new_cancelled_lessons.should == 0
      lesson.destroy 
    end

    it "calculates number of paid classes ran" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 2.days.ago, cost: 0)
      lesson2.channels << @channel
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.paid_lessons.should == 5
    end

    it "calculates number of paid classes ran in previous time period" do
      lesson2 = FactoryGirl.create(:lesson, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 5.days.ago, cost: 0)
      lesson2.channels << @channel
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.previous.paid_lessons.should == 3
    end

    it "calculates percentage change in paid lessons ran" do
      @channel.channel_stats(3.days.ago,3.days).lesson_stats.percent_paid_lessons.to_f.should be_within(0.00001).of(2.0/3.0*100.0)
    end
  
  end
end

