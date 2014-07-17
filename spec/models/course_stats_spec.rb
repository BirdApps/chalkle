require 'spec_helper'
include Faker

describe "Chalkler_stats" do

  describe "Course activity statistics" do

    let(:chalkler) { FactoryGirl.create(:chalkler) }
    let(:channel) { FactoryGirl.create(:channel, channel_rate_override: 0.2, teacher_percentage: 0.5) }
    let(:repeat_course) { FactoryGirl.create(:repeat_course) }

    before(:each) do
      # lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago)
      # FactoryGirl.create(:course, channel: channel, lessons: [lesson], status: "Published")
      # lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago)
      # FactoryGirl.create(:course, channel: channel, lessons: [lesson], status: "Unreviewed")
      # lesson = FactoryGirl.create(:lesson, start_at: 4.days.ago)
      # FactoryGirl.create(:course, channel: channel, lessons: [lesson], status: "Published")

      (1..5).each do |i|
        lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago)
        course = FactoryGirl.create(:course, lessons: [lesson], status: "Published", channel: channel)

        booking = FactoryGirl.create(:booking, course: course, guests: i-1, chalkler: chalkler, paid: true, status: "yes")

        FactoryGirl.create(:payment, booking: booking, total: i*10*1.15, reconciled: true, cash_payment: true)
      end

      (6..8).each do |i|

        lesson = FactoryGirl.create(:lesson, start_at: 5.days.ago)
        course = FactoryGirl.create(:course, lessons: [lesson], status: "Published", channel: channel)

        booking = FactoryGirl.create(:booking, course: course, guests: i-1, chalkler: chalkler, paid: true, status: "yes")

        FactoryGirl.create(:payment, booking: booking, total: i*10*1.15, reconciled: true, cash_payment: false)
      end


      lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago)
      course1 = FactoryGirl.create(:course, name: "Cancelled course 1", status: "Published", lessons: [lesson], cost: 10, channel: channel, repeat_course: repeat_course)
      course1.update_attributes({:visible => false}, :as => :admin)


      lesson = FactoryGirl.create(:lesson, start_at: 5.days.ago)
      course2 = FactoryGirl.create(:course, name: "Cancelled course 2", status: "Published", lessons: [lesson], cost: 10, channel: channel)
      course2.update_attributes({:visible => false}, :as => :admin)
    end

    it "calculates number of visible courses announced" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.courses_announced).to eq 5
    end

    it "calculates number of visible courses announced in the previous time period" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.previous.courses_announced).to eq 3
    end

    it "calculates percentage change in courses announced" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.percent_courses_announced).to be_within(0.1).of(66.66)
    end

    it "calculates number of classes ran" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.courses_ran).to eq 5
    end

    it "calculates number of classes ran in the previous time period" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.previous.courses_ran).to eq 3
    end

    it "calculates percentage change in number of classes ran" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.percent_courses_ran.to_f).to be_within(0.00001).of(2.0/3.0*100.0)
    end

    it "calculates number of new classes ran" do
      course2 = FactoryGirl.create(:course, name: "test class 1", status: "Published", lessons: [FactoryGirl.create(:lesson, start_at: 50.days.ago)], channel: channel, repeat_course: repeat_course)
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.new_courses_ran).to eq 5
    end

    it "calculates number of cancelled classes" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.cancelled_courses).to eq 1
    end

    it "calculates number of cancelled classes in previous time period" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.previous.cancelled_courses).to eq 1 
    end

    it "calculates number of new cancelled classes" do
      course = FactoryGirl.create(:course, name: "Cancelled course 1", status: "Published", lessons: [FactoryGirl.create(:lesson, start_at: 10.days.ago)], cost: 10, channel: channel)
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.new_cancelled_courses).to eq 0
      course.destroy 
    end

    it "calculates number of paid classes ran" do
      course2 = FactoryGirl.create(:course, meetup_id: 1234567, name: "test class 1", status: "Published", lessons: [FactoryGirl.create(:lesson, start_at: 2.days.ago)], cost: 0, channel: channel)
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.paid_courses).to eq 5
    end

    it "calculates number of paid classes ran in previous time period" do
      course2 = FactoryGirl.create(:course, meetup_id: 1234567, name: "test class 1", status: "Published", lessons: [FactoryGirl.create(:lesson, start_at: 5.days.ago)], cost: 0, channel: channel)
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.previous.paid_courses).to eq 3
    end

    it "calculates percentage change in paid courses ran" do
      expect(channel.channel_stats(3.days.ago,3.days).course_stats.percent_paid_courses.to_f).to be_within(0.00001).of(2.0/3.0*100.0)
    end
    
  end
end

