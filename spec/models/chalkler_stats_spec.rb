require 'spec_helper'

describe "Chalkler_stats" do

  describe "Membership Statistics" do

    before do 
      @channel = FactoryGirl.create(:channel)
      @lesson1 = FactoryGirl.create(:lesson, name: "test 1")
      @lesson2 = FactoryGirl.create(:lesson, name: "test 2")
      (1..5).each do |i|
        chalkler = FactoryGirl.create(:chalkler, meetup_id: i*11111111, email: "test#{i}@gmail.com", created_at: 1.year.ago)
        chalkler.channels << @channel
        FactoryGirl.create(:booking, lesson_id: @lesson1.id, chalkler_id: chalkler.id, created_at: i.months.ago)
        FactoryGirl.create(:booking, lesson_id: @lesson2.id, chalkler_id: chalkler.id, created_at: i.months.ago)
      end    
    end

    it "calculates the number of new members" do
      chalkler2 = FactoryGirl.create(:chalkler, meetup_id: 1234565, email: "test@gmail.com", created_at: 1.day.ago)
      chalkler2.channels << @channel
      @channel.channel_stats(7.days.ago,7.days).chalkler_stats.new_chalklers.should == 1
    end

    it "calculates number of new members in previous time period" do
      chalkler3 = FactoryGirl.create(:chalkler, meetup_id: 1234563, email: "newuser3@gmail.com", created_at: 10.days.ago)
      chalkler4 = FactoryGirl.create(:chalkler, meetup_id: 1234564, email: "newuser4@gmail.com", created_at: 10.days.ago)
      chalkler3.channels << @channel
      chalkler4.channels << @channel
      @channel.channel_stats(7.days.ago,7.days).chalkler_stats.previous.new_chalklers.should == 2
    end 

    it "calculates percentage change in number of new members" do
      chalkler2 = FactoryGirl.create(:chalkler, meetup_id: 1234562, email: "newuser2@gmail.com", created_at: 1.day.ago)
      chalkler3 = FactoryGirl.create(:chalkler, meetup_id: 1234563, email: "newuser3@gmail.com", created_at: 10.days.ago)
      chalkler4 = FactoryGirl.create(:chalkler, meetup_id: 1234564, email: "newuser4@gmail.com", created_at: 10.days.ago)
      chalkler2.channels << @channel
      chalkler3.channels << @channel
      chalkler4.channels << @channel
      @channel.channel_stats(7.days.ago,7.days).chalkler_stats.percent_new_chalklers.should == -50.0
    end 

    it "calculates the percentage of active members" do
      @channel.channel_stats(7.days.ago,7.days).chalkler_stats.percent_active.should == 40.0
    end
  end

  describe "Chalkler activity statistics" do
    before do
      @channel = FactoryGirl.create(:channel, channel_percentage: 0.2, teacher_percentage: 0.5)
      @chalkler = FactoryGirl.create(:chalkler)
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
    end

    it "calculates total attendee" do
      @channel.channel_stats(3.days.ago,3.days).chalkler_stats.attendee.should == 15
    end

    it "calculates total attendee in previous time period" do
      @channel.channel_stats(3.days.ago,3.days).chalkler_stats.previous.attendee.should == 21
    end

    it "calculates percentage change in number of attendees" do
      @channel.channel_stats(3.days.ago,3.days).chalkler_stats.percent_attendee.to_f.should == -(6.0/21.0*100.0)
    end

    it "calculates fill fraction" do
      @channel.channel_stats(3.days.ago,3.days).chalkler_stats.fill_fraction.should == 30
    end

  end

end
