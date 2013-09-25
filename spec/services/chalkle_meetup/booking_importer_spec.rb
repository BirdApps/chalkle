require 'spec_helper'
require 'chalkle_meetup/booking_importer'

describe ChalkleMeetup::BookingImporter do
  describe ".import" do
    let(:data) { MeetupApiStub::rsvp_response }
    let!(:chalkler) { FactoryGirl.create(:chalkler, meetup_id: 12345678) }
    let!(:lesson) { FactoryGirl.create(:lesson, meetup_id: 12345678) }

    it "creates a valid Booking" do
      booking = subject.import(data)
      booking.should be_valid
    end

    it "updates existing booking" do
      booking = FactoryGirl.create(:booking, meetup_id: 12345678, chalkler: chalkler, lesson: lesson, guests: 20)
      subject.import(data)
      booking.reload.guests.should == 1
    end

    it "saves valid meetup_data" do
      booking = subject.import(data)
      booking.meetup_data["rsvp_id"].should == 12345678
      booking.meetup_data["member"]["member_id"].should == 12345678
    end

    it "won't update past classes" do
      booking = FactoryGirl.create(:booking, meetup_id: 12345678, chalkler: chalkler, lesson: lesson, guests: 20)
      lesson.start_at = Chronic.parse("a year ago")
      lesson.save
      subject.import(data)
      booking.reload.guests.should == 20
    end

    it "saves correct time value" do
      booking = subject.import(data)
      booking.created_at.to_time.to_i.should == 1351297791
      booking.updated_at.to_time.to_i.should == 1351297791
    end
  end
end
