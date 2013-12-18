require 'spec_helper'

describe BookingReminder do
  describe "#initialize" do
    let(:chalkler){ FactoryGirl.build(:chalkler) }
    let(:reminder) { BookingReminder.new(chalkler, 3.days) }

    it "sets @chalkler" do
      reminder.instance_eval{ @chalkler }.should == chalkler
    end

    it "sets starting time of lessons to be reminded" do
      reminder.instance_eval{ @lesson_start_in }.should == 3.days
    end

  end

  describe "booking selection" do
    before do
      teacher = FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com")
      @chalkler = FactoryGirl.create(:chalkler, name: "Michael Jackson", email: "michael@jackson.com")
      @channel = FactoryGirl.create(:channel, name: "Music")
      @lesson = FactoryGirl.create(:lesson, name: "Chalkle Class 5", start_at: 3.days.from_now, cost: 10, teacher_id: teacher.id, visible: true)
      @lesson.channels << @channel
      @booking = FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: @lesson.id, status: 'yes', visible: true, paid: false)
      @reminder = BookingReminder.new(@chalkler,3.days)
    end

    it "loads booking for reminder" do
      result = @reminder.instance_eval{ remind_now }
      result.should == [@booking]
      result.first.should_not be_readonly
    end

    it "won't load hidden bookings" do
      @booking.update_attributes({:visible => false}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @booking.update_attributes({:visible => true}, :as => :admin)
    end

    it "won't load bookings without a yes status" do
      @booking.update_attributes({:status => 'waitlist'}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @booking.update_attributes({:status => 'yes'}, :as => :admin)
    end

    it "won't load booking for a free class" do
      @lesson.update_attributes({:cost => 0}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @lesson.update_attributes({:cost => 10}, :as => :admin)
    end

    it "won't load free booking" do
      @booking.update_attributes({:cost_override => 0}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @booking.update_attributes({:cost_override => 0}, :as => :admin)
    end

    it "won't load a paid booking" do
      @booking.update_attributes({:paid => true}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @booking.update_attributes({:paid => false}, :as => :admin)
    end

    it "won't load booking from lessons in the past" do
      @lesson.update_attributes({:start_at => 2.days.ago}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @lesson.update_attributes({:start_at => 3.days.from_now}, :as => :admin)
    end

    it "won't load booking by the teacher" do
      @booking.update_attributes({:chalkler_id => @lesson.teacher_id}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @booking.update_attributes({:chalkler_id => @chalkler.id}, :as => :admin)
    end

    it "won't load booking for a lesson without a channel" do
      @lesson.channels = []
      @reminder.instance_eval{ remindable }.should be_empty
      @lesson.channels << @channel
    end

    it "won't load booking for a lesson without a start date" do
      @lesson.update_attributes({:start_at => nil}, :as => :admin)
      @reminder.instance_eval{ remindable }.should be_empty
      @lesson.update_attributes({:start_at => 3.days.from_now}, :as => :admin)
    end

    it "won't load booking from lessons more than 3 days away" do
      @lesson.update_attributes({:start_at => 4.days.from_now}, :as => :admin)
      @reminder.instance_eval{ remind_now }.should be_empty
      @lesson.update_attributes({:start_at => 3.days.from_now}, :as => :admin)
    end

    it "won't load booking from lessons less than 3 days away" do
      @lesson.update_attributes({:start_at => 2.days.from_now}, :as => :admin)
      @reminder.instance_eval{ remind_now }.should be_empty
      @lesson.update_attributes({:start_at => 3.days.from_now}, :as => :admin)
    end

    it "will sort lessons in order of start time" do
      lesson = FactoryGirl.create(:lesson, name: "An earlier lesson", cost: 5, teacher_id: @lesson.teacher_id, visible: true, start_at: @lesson.start_at - 5.hours)
      lesson.channels << @channel
      booking = FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: lesson.id, status: 'yes', paid: false, visible: true)
      @reminder.instance_eval{ remind_now }.should == [booking, @booking]
    end
  
  end

  describe ".log_times" do
    it "record current time in reminder email sent" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson)
      booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler)
      reminder = BookingReminder.new(chalkler, 3.days)
      reminder.instance_eval {log_times([booking])}
      booking.reminder_last_sent_at.to_i.should == Time.now.to_time.to_i
    end
  end
    
  describe ".load_chalklers" do
    before do
      @chalkler = FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com")
      @chalkler1 = FactoryGirl.create(:chalkler, email: nil, uid: '12345678', provider: 'meetup')
      @lesson = FactoryGirl.create(:lesson, name: "Chalkle Class 5", start_at: 3.days.from_now, cost: 10, visible: true)
      FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: @lesson.id, status: 'yes', visible: true, paid: false)
      FactoryGirl.create(:booking, chalkler_id: @chalkler1.id, lesson_id: @lesson.id, status: 'yes', visible: true, paid: false)
    end

    it "won't return a chalkler without an email address" do
      BookingReminder.load_chalklers.should_not include(@chalkler1)
    end

    it "return a chalkler with an email address" do
      BookingReminder.load_chalklers.should include(@chalkler)
    end

    it "won't return duplicated chalklers" do
      lesson2 = FactoryGirl.create(:lesson, name: "Another lesson", start_at: 3.days.from_now, cost: 10, visible: true)
      FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: lesson2.id, status: 'yes', visible: true, paid: false)
      BookingReminder.load_chalklers.should == [@chalkler]
    end
  end

end
