require 'spec_helper'

describe "Chalkler_stats" do

  describe "Course activity statistics" do

    let(:chalkler){ FactoryGirl.create(:chalkler) }
    let(:channel) { FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5) }

    before(:all) do
      @chalkler = FactoryGirl.create(:chalkler)
      @channel = FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5)
      (1..5).each do |i|
        course = FactoryGirl.create(:course, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, start_at: 2.days.ago, status: "Published", max_attendee: 10, channel: @channel)
        booking = FactoryGirl.create(:booking, course_id: course.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: false)
        end
      end
      (6..8).each do |i|
        course = FactoryGirl.create(:course, meetup_id: i*11111111, name: "test class #{i}", cost: i*10, teacher_cost: i*5, teacher_payment: i*5, start_at: 5.days.ago, status: "Published", max_attendee: 10, channel: @channel)
        booking = FactoryGirl.create(:booking, course_id: course.id, guests: i-1, chalkler_id: @chalkler.id, paid: true, status: "yes")
        if (i == 5)
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: true)
        else
          FactoryGirl.create(:payment, booking_id: booking.id, total: i*10*1.15, reconciled: true, cash_payment: false)
        end
      end
      course1 = FactoryGirl.create(:course, name: "Cancelled course 1", status: "Published", start_at: 2.days.ago, cost: 10, channel: @channel)
      course1.update_attributes({:visible => false}, :as => :admin)
      course2 = FactoryGirl.create(:course, name: "Cancelled course 2", status: "Published", start_at: 5.days.ago, cost: 10, channel: @channel)
      course2.update_attributes({:visible => false}, :as => :admin)
    end

    it "calculates number of visible courses announced" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.courses_announced).to eq 5
    end

    it "calculates number of visible courses announced in the previous time period" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.previous.courses_announced).to eq 3
    end

    it "calculates percentage change in courses announced" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.percent_courses_announced).to be_within(0.1).of(66.66)
    end

    it "calculates number of classes ran" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.courses_ran).to eq 5
    end

    it "calculates number of classes ran in the previous time period" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.previous.courses_ran).to eq 3
    end

    it "calculates percentage change in number of classes ran" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.percent_courses_ran.to_f).to be_within(0.00001).of(2.0/3.0*100.0)
    end

    it "calculates number of new classes ran" do
      course2 = FactoryGirl.create(:course, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 50.days.ago, channel: @channel)
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.new_courses_ran).to eq 4
    end

    it "calculates number of cancelled classes" do
      expect(@channel.channel_stats(3.days.ago,3.days.from_now).course_stats.cancelled_courses.count).to eq 1
    end

    it "calculates number of cancelled classes in previous time period" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.previous.cancelled_courses.count).to eq 1 
    end

    it "calculates number of new cancelled classes" do
      course = FactoryGirl.create(:course, name: "Cancelled course 1", status: "Published", start_at: 10.days.ago, cost: 10, channel: @channel)
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.new_cancelled_courses).to eq 0
      course.destroy 
    end

    it "calculates number of paid classes ran" do
      course2 = FactoryGirl.create(:course, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 2.days.ago, cost: 0, channel: @channel)
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.paid_courses).to eq 5
    end

    it "calculates number of paid classes ran in previous time period" do
      course2 = FactoryGirl.create(:course, meetup_id: 1234567, name: "test class 1", status: "Published", start_at: 5.days.ago, cost: 0, channel: @channel)
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.previous.paid_courses).to eq 3
    end

    it "calculates percentage change in paid courses ran" do
      expect(@channel.channel_stats(3.days.ago,3.days).course_stats.percent_paid_courses.to_f).to be_within(0.00001).of(2.0/3.0*100.0)
    end
  
  end
end

