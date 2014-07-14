require 'spec_helper'

describe BookingReminder do
  describe "#initialize" do
    let(:chalkler){ FactoryGirl.build(:chalkler) }
    let(:reminder) { BookingReminder.new(chalkler, 3.days) }

    it "sets @chalkler" do
      expect(reminder.instance_eval{ @chalkler }).to be(chalkler)
    end

    it "sets starting time of lessons to be reminded" do
      expect(reminder.instance_eval{ @lesson_start_in }).to eq(3.days)
    end

  end

  describe "booking selection" do
    before do
      teacher = FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com")
      @chalkler = FactoryGirl.create(:chalkler, name: "Michael Jackson", email: "michael@jackson.com")
      @channel = FactoryGirl.create(:channel, name: "Music", visible: true)
      @lesson = FactoryGirl.create(:lesson, name: "Chalkle Class 5", start_at: 3.days.from_now, cost: 10, teacher_id: teacher.id, visible: true, channel: @channel)
      @booking = FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: @lesson.id, status: 'yes', visible: true, paid: false)
      @reminder = BookingReminder.new(@chalkler,3.days)
    end

    it "loads booking for reminder" do
      result = @reminder.remind_now
      expect(result).to eq( [@booking] )
      expect(result.first).to be_readonly
    end

    it "won't load hidden bookings" do
      @booking.update_attributes({:visible => false}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @booking.update_attributes({:visible => true}, :as => :admin)
    end

    it "won't load bookings without a yes status" do
      @booking.update_attributes({:status => 'waitlist'}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @booking.update_attributes({:status => 'yes'}, :as => :admin)
    end

    it "won't load booking for a free class" do
      @lesson.update_attributes({:cost => 0}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @lesson.update_attributes({:cost => 10}, :as => :admin)
    end

    it "won't load free booking" do
      @booking.update_attributes({:cost_override => 0}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @booking.update_attributes({:cost_override => 0}, :as => :admin)
    end

    it "won't load a paid booking" do
      @booking.update_attributes({:paid => true}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @booking.update_attributes({:paid => false}, :as => :admin)
    end

    it "won't load booking from lessons in the past" do
      @lesson.update_attributes({:start_at => 2.days.ago}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @lesson.update_attributes({:start_at => 3.days.from_now}, :as => :admin)
    end

    it "won't load booking by the teacher" do
      @booking.update_attributes({:chalkler_id => @lesson.teacher_id}, :as => :admin)
      expect(@reminder.remindable).to be_empty
      @booking.update_attributes({:chalkler_id => @chalkler.id}, :as => :admin)
    end

    it "won't load booking for a lesson without a channel" do
      @lesson.channel = nil
      @lesson.save
      expect(@reminder.remindable).to eq( [] )
    end

    it "won't load booking for a lesson without a start date" do
      @lesson.update_attributes({:start_at => nil}, :as => :admin)
      expect( @reminder.remindable).to eq( [] )
    end

    it "won't load booking from lessons in the past" do
      @lesson.update_attributes({:start_at => 2.days.ago}, :as => :admin)
      expect( @reminder.remindable).to eq( [] )
    end

    it "will sort lessons in order of start time" do
      lesson = FactoryGirl.create(:lesson, name: "An earlier lesson", cost: 5, teacher_id: @lesson.teacher_id, visible: true, start_at: @lesson.start_at - 5.hours, channel: @channel)
      booking = FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: lesson.id, status: 'yes', paid: false, visible: true)
      expect( @reminder.remind_now).to eq( [booking, @booking] )
    end
  
  end

  describe ".log_times" do
    it "record current time in reminder email sent" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson)
      booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler)
      reminder = BookingReminder.new(chalkler, 3.days)
      reminder.log_times([booking])
      expect(booking.reminder_last_sent_at.to_i).to eq( Time.now.to_time.to_i )
    end
  end
    
  describe ".load_chalklers" do
    before do
      @chalkler = FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com")
      @chalkler1 = FactoryGirl.create(:chalkler, name: "Miley Cyrus", email: "mileycyrus@spears.com")
      @chalkler1.update_attribute(:email, nil)
      @lesson = FactoryGirl.create(:lesson, name: "Chalkle Class 5", start_at: 3.days.from_now, cost: 10, visible: true)
      FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: @lesson.id, status: 'yes', visible: true, paid: false)
      FactoryGirl.create(:booking, chalkler_id: @chalkler1.id, lesson_id: @lesson.id, status: 'yes', visible: true, paid: false)
    end

    it "won't return a chalkler without an email address" do
      expect(BookingReminder.load_chalklers).not_to include(@chalkler1)
    end

    it "return a chalkler with an email address" do
      expect(BookingReminder.load_chalklers).to include(@chalkler)
    end

    it "won't return duplicated chalklers" do
      lesson2 = FactoryGirl.create(:lesson, name: "Another lesson", start_at: 3.days.from_now, cost: 10, visible: true)
      FactoryGirl.create(:booking, chalkler_id: @chalkler.id, lesson_id: lesson2.id, status: 'yes', visible: true, paid: false)
      expect( BookingReminder.load_chalklers ).to eq [@chalkler]
    end
  end

end
