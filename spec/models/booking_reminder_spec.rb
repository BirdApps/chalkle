require 'spec_helper'

describe BookingReminder do
  describe "#initialize" do
    let(:chalkler) { FactoryGirl.build(:chalkler) }
    let(:reminder) { BookingReminder.new(chalkler, 3.days) }

    it "sets @chalkler" do
      expect(reminder.instance_eval{ @chalkler }).to be(chalkler)
    end

    it "sets starting time of courses to be reminded" do
      expect(reminder.instance_eval{ @course_start_in }).to eq 3.days
    end

  end

  describe "booking selection" do
    let(:teacher) { FactoryGirl.create(:chalkler, name: "Britany Spears", email: "britany@spears.com") }
    let(:chalkler) { FactoryGirl.create(:chalkler, name: "Michael Jackson", email: " michael@jackson.com") }
    let(:channel) { FactoryGirl.create(:channel, name: "Music", visible: true) }
    let(:lesson) { FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 1) }
    let(:course) { FactoryGirl.create(:published_course, name: "Chalkle Class 5", lessons: [lesson],  cost: 10, teacher_id: teacher.id, visible: true, channel: channel) }
    let!(:booking) { FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id:  course.id, status: 'yes', visible: true, paid: false) }
    let!(:reminder) { BookingReminder.new(chalkler,3.days) }

    it "loads booking for reminder" do
      result = reminder.remind_now
      expect(result).to eq( [booking] )
    end

    it "won't load hidden bookings" do
      booking.update_attributes({:visible => false}, :as => :admin)
      expect(reminder.remindable).to be_empty
      booking.update_attributes({:visible => true}, :as => :admin)
    end

    it "won't load bookings without a yes status" do
      booking.update_attributes({:status => 'waitlist'}, :as => :admin)
      expect(reminder.remindable).to be_empty
      booking.update_attributes({:status => 'yes'}, :as => :admin)
    end

    it "won't load booking for a free class" do
      course.update_attributes({:cost => 0}, :as => :admin)
      expect(reminder.remindable).to be_empty
      course.update_attributes({:cost => 10}, :as => :admin)
    end

    it "won't load free booking" do
      booking.update_attributes({:cost_override => 0}, :as => :admin)
      expect(reminder.remindable).to be_empty
      booking.update_attributes({:cost_override => 0}, :as => :admin)
    end

    it "won't load a paid booking" do
      booking.update_attributes({:paid => true}, :as => :admin)
      expect(reminder.remindable).to be_empty
      booking.update_attributes({:paid => false}, :as => :admin)
    end

    it "won't load booking from courses in the past" do
      course.lessons = [FactoryGirl.create(:lesson, start_at: 2.days.ago)]
      expect(reminder.remindable).to be_empty
      course.lessons = [FactoryGirl.create(:lesson, start_at: 3.days.from_now)]
    end

    it "won't load booking by the teacher" do
      booking.update_attributes({:chalkler_id => course.teacher_id}, :as => :admin)
      expect(reminder.remindable).to be_empty
      booking.update_attributes({:chalkler_id => chalkler.id}, :as => :admin)
    end

    it "won't load booking for a course without a start date" do
      course.lessons=[]
      expect(reminder.remindable).to eq []
    end

    it "won't load booking from courses in the past" do
      course.lessons = [FactoryGirl.create(:lesson, start_at: 2.days.ago)]
      expect(reminder.remindable).to eq []
    end

    it "will sort courses in order of start time" do
      lesson_earlier = FactoryGirl.create(:lesson, start_at: course.start_at - 5.hours, duration: 1)
      course_earlier = FactoryGirl.create(:published_course, name: "An earlier course", cost: 5, visible: true, lessons: [lesson_earlier], channel: channel)
      booking_earlier = FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course_earlier.id, status: 'yes', paid: false, visible: true)
      expect(reminder.remind_now).to eq [booking_earlier, booking]
    end
  
  end

  describe ".log_times" do
    it "record current time in reminder email sent" do
      chalkler = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course)
      booking = FactoryGirl.create(:booking, course: course, chalkler: chalkler)
      reminder = BookingReminder.new(chalkler, 3.days)
      reminder.log_times([booking])
      expect(booking.reminder_last_sent_at.to_i).to eq( Time.now.to_time.to_i )
    end
  end
    
  describe ".load_chalklers" do
    let(:chalkler) { FactoryGirl.create(:chalkler, name: "Brittany Spears", email: "brittany@spears.com") }
    let(:chalkler1) { c = FactoryGirl.build(:chalkler, name: "Miley Cyrus", email: nil).save(validate: false)
     c }
    let(:lesson) { FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 1) }
    let(:course) { FactoryGirl.create(:published_course, name: "Chalkle Class 5", lessons: [lesson], cost: 10, visible: true) }
    let(:course2) { FactoryGirl.create(:published_course, name: "Another course", lessons: [lesson], cost: 10, visible: true) }
    let!(:booking) { FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, status: 'yes', visible: true, paid: false) }
    let(:booking1) { FactoryGirl.create(:booking, chalkler_id: chalkler1.id, course_id: course.id, status: 'yes', visible: true, paid: false) }

    it "won't return a chalkler without an email address" do
      expect(BookingReminder.load_chalklers).not_to include(chalkler1)
    end

    it "return a chalkler with an email address" do
      expect(BookingReminder.load_chalklers).to include(chalkler)
    end

    it "won't return duplicated chalklers" do
      FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course2.id, status: 'yes', visible: true, paid: false)
      expect(BookingReminder.load_chalklers).to eq [chalkler]
    end
  end

end
