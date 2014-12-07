require 'spec_helper'

describe Booking do
  describe "resource creation" do
    specify { expect(FactoryGirl.build(:booking)).to be_valid }

    it { should validate_presence_of(:course_id) }
    it { should validate_presence_of(:chalkler_id) }


  end

  describe ".confirmed" do
    let(:booking_unconfirmed) {FactoryGirl.create(:booking, status: 'no')}
    let(:booking) {FactoryGirl.create(:booking, status: 'yes')}


    it "excludes unconfirmed bookings" do
      expect(Booking.confirmed).not_to include(booking_unconfirmed)
    end

    it "includes confirmed bookings" do
      expect(Booking.confirmed).to include(booking)
    end
  end


  describe ".upcoming" do
      let(:lesson) { FactoryGirl.create(:lesson, start_at: 2.days.from_now, duration: 1.5) }
      let(:lesson_earlier) { FactoryGirl.create(:lesson, start_at: 2.days.ago) }
      let(:course) { FactoryGirl.create(:course, lessons: [lesson], visible: true) }
      let(:course_earlier) { FactoryGirl.create(:course, lessons: [lesson_earlier], visible: true) }
      let(:booking) { FactoryGirl.create(:booking, course: course) }
      let(:booking_earlier) { FactoryGirl.create(:booking, course: course_earlier) }
    
    it "includes booking for courses in the future" do
      expect(Booking.upcoming).to include(booking)
    end

    it "excludes bookings for courses in the past" do
      expect(Booking.upcoming).not_to include(booking_earlier)
    end

    it "excludes bookings for cancelled courses" do
      course.visible = false
      course.save
      expect(Booking.upcoming).not_to include(booking)
    end
  end

  describe "#name" do
    let(:booking) { FactoryGirl.create(:course) }
    it "creates name when course and chalkler present" do
      expect(booking.name).to eq "Learning fun"
    end
  end

  describe ".visible" do
    let(:booking) { FactoryGirl.create(:booking) }
    it {expect(Booking.visible).to include(booking)}

    it "should not include a hidden booking" do
      booking.update_attribute :visible, false
      expect(Booking.visible).not_to include(booking)
    end
  end

  describe ".hidden" do
    let(:booking) { FactoryGirl.create(:booking) }
    it "includes hidden bookings" do
      booking.update_attribute :visible, false
      expect(Booking.hidden).to include(booking)
    end

    it {expect(Booking.hidden).not_to include(booking)}
  end

  
  describe "#cancelled?" do
    let(:booking) { FactoryGirl.create(:booking) }
    it "reurns true if booking is cancelled" do
      booking.cancel!
      expect(booking.cancelled?).to be true
    end

    it "returns false if booking is not cancelled" do
      expect(FactoryGirl.build(:booking, status: 'yes').cancelled?).to be false
    end
  end
end

