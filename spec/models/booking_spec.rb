require 'spec_helper'

describe Booking do
  describe "resource creation" do
    specify { expect(FactoryGirl.build(:booking)).to be_valid }

    it { should validate_presence_of(:course_id) }
    it { should validate_presence_of(:chalkler_id) }

  end

  describe "creates free bookings" do 
    let(:booking) {FactoryGirl.create(:booking_free)}
    it "creates a free booking" do 
      expect(booking).to be_valid
    end
  end

  describe "creates paid bookings" do 
    let(:booking) {FactoryGirl.create(:booking)}
    it "creates a paid booking" do 
      expect(booking).to be_valid
    end
    it "ensures booking cost equals course cost" do
      expect(booking.cost).to eq(booking.course.cost)
    end
  end

  describe ".confirmed" do
    let!(:booking_unconfirmed) {FactoryGirl.create(:booking, status: 'no')}
    let!(:booking) {FactoryGirl.create(:booking, status: 'yes')}


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

    it "excludes cancelled bookings" do
      booking.cancel!
      expect(Booking.upcoming).not_to include(booking)
    end
  end

  describe "#name" do
    let(:booking) { FactoryGirl.create(:booking) }
    it "creates name when course and chalkler present" do
      expect(booking.name).to eq "Joe Groot"
    end
  end

  describe ".visible" do
    let!(:booking) { FactoryGirl.create(:booking) }
    let!(:hidden_booking) { FactoryGirl.create(:hidden_booking) }
    
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

