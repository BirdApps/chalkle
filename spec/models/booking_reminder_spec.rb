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
    let(:chalkler) { FactoryGirl.create(:chalkler) }
    let(:channel) { FactoryGirl.create(:channel, name: "Music", visible: true) }
    let(:lesson) { FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 1) }
    let(:course) { FactoryGirl.create(:published_course, name: "Chalkle Class 5", lessons: [lesson],  cost: 10, visible: true, channel: channel) }
    let!(:booking) { FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id:  course.id, status: 'yes', visible: true) }
    let!(:payment) { FactoryGirl.create(:payment, total: 10, booking_id: booking.id) }
    let!(:reminder) { BookingReminder.new(chalkler,3.days) }

    let(:lesson_earlier) { FactoryGirl.create(:lesson, start_at: course.start_at - 5.hours, duration: 1) }
    let(:course_earlier) { FactoryGirl.create(:published_course, name: "An earlier course", cost: 5, visible: true, lessons: [lesson_earlier], channel: channel) }

    let(:booking_earlier) { FactoryGirl.create(:booking, chalkler: chalkler, course: course_earlier, status: 'yes', payment: nil, visible: true) } 


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

    it "won't load a paid booking" do
      payment(booking: booking)
      expect(reminder.remindable).to be_empty
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

    it "will sort courses in order of start time" do
      booking_earlier
      booking
      expect(reminder.remind_now).to eq [booking_earlier, booking]
    end

  end
    
  describe ".load_chalklers" do
    let(:chalkler) { FactoryGirl.create(:chalkler, name: "Brittany Spears", email: "brittany@spears.com") }
    let(:chalkler1) { c = FactoryGirl.build(:chalkler, name: "Miley Cyrus", email: nil).save(validate: false)
     c }
    let(:lesson) { FactoryGirl.create(:lesson, start_at: 3.days.from_now, duration: 1) }
    let(:course) { FactoryGirl.create(:published_course, name: "Chalkle Class 5", lessons: [lesson], cost: 10, visible: true) }
    let(:course2) { FactoryGirl.create(:published_course, name: "Another course", lessons: [lesson], cost: 10, visible: true) }
    let!(:booking) { FactoryGirl.create(:booking, chalkler_id: chalkler.id, course_id: course.id, status: 'yes', visible: true, payment: nil) }
    let(:booking1) { FactoryGirl.create(:booking, chalkler_id: chalkler1.id, course_id: course.id, status: 'yes', visible: true, paid: false) }

    it "won't return a chalkler without an email address" do
      expect(BookingReminder.load_chalklers).not_to include(chalkler1)
    end

  end

end
