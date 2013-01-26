require 'spec_helper'

describe Booking do
  it { should belong_to(:lesson) }
  it { should belong_to(:chalkler) }
  it { should have_one(:payment) }

  it { should validate_presence_of(:lesson_id) }
  it { should validate_presence_of(:chalkler_id) }
  pending { should validate_uniqueness_of(:chalkler_id) }

  describe "#cost" do
    it "returns nil when lesson has no cost" do
      lesson = FactoryGirl.create(:lesson, cost: nil)
      booking = FactoryGirl.create(:booking, guests: 5, lesson: lesson)
      booking.cost.should be_nil
    end

    it "returns cost from lesson" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, guests: 0, lesson: lesson)
      booking.cost.to_f.should == 10
    end

    it "calculates cost when booking has no guests" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, guests: nil, lesson: lesson)
      booking.cost.to_f.should == 10
    end

    it "calculates cost when booking has guests" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking =  FactoryGirl.create(:booking, guests: 9, lesson: lesson)
      booking.cost.to_f.should == 100
    end

    it "sets a correct cost_override" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking =  FactoryGirl.create(:booking, cost_override: 20, lesson: lesson)
      booking.cost.to_f.should == 20
    end
  end

  describe ".paid" do
    it "excludes unpaid bookings" do
      booking = FactoryGirl.create(:booking, paid: nil)
      Booking.paid.should_not include(booking)
    end

    it "includes paid bookings" do
      booking = FactoryGirl.create(:booking, paid: true)
      Booking.paid.should include(booking)
    end
  end

  describe ".unpaid" do
    it "excludes paid bookings" do
      booking = FactoryGirl.create(:booking, paid: true)
      Booking.unpaid.should_not include(booking)
    end

    it "includes unpaid bookings" do
      booking = FactoryGirl.create(:booking, paid: nil)
      Booking.unpaid.should include(booking)
    end
  end

  describe ".confirmed" do
    it "excludes unconfirmed bookings" do
      booking = FactoryGirl.create(:booking, status: "waitlist")
      Booking.confirmed.should_not include(booking)
    end

    it "includes confirmed bookings" do
      booking = FactoryGirl.create(:booking, status: "yes")
      Booking.confirmed.should include(booking)
    end
  end

  describe ".waitlist" do
    it "excludes confirmed bookings" do
      booking = FactoryGirl.create(:booking, status: "yes")
      Booking.waitlist.should_not include(booking)
    end

    it "includes waitlisted bookings" do
      booking = FactoryGirl.create(:booking, status: "waitlist")
      Booking.waitlist.should include(booking)
    end
  end

  describe ".billable" do
    it "excludes bookings with a zero cost" do
      lesson = FactoryGirl.create(:lesson, cost: 0)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      Booking.billable.should_not include(booking)
    end

    it "includes bookings that have a cost" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      Booking.billable.should include(booking)
    end

    context "booking belongs to the teacher" do
      let(:teacher) { FactoryGirl.create(:chalkler, email: "example@testy.com", meetup_id: 1234)}
      let(:lesson) { FactoryGirl.create(:lesson, teacher: teacher, cost: 10) }

      it "is included with guests" do
        booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: teacher, guests: 1)
        Booking.billable.should include(booking)
      end

      it "is excluded without guests" do
        booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: teacher, guests: nil)
        Booking.billable.should_not include(booking)
      end
    end
  end

  describe "#name" do
    it "creates name when lesson and chalkler present" do
      lesson = FactoryGirl.create(:lesson, name: "lesson_name", meetup_id: 12345678)
      chalkler = FactoryGirl.create(:chalkler, name: "chalkler_name")
      booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler)
      booking.name.should == "lesson_name (12345678) - chalkler_name"
    end
  end

  describe ".create_from_meetup_hash" do
    let(:result) { MeetupApiStub::rsvp_response }
    let!(:chalkler) { FactoryGirl.create(:chalkler, meetup_id: 12345678) }
    let!(:lesson) { FactoryGirl.create(:lesson, meetup_id: 12345678) }
    let(:return_value) { Booking.create_from_meetup_hash result }

    it "creates a valid Booking" do
      return_value.should be_true
      Booking.find_by_meetup_id(12345678).should be_valid
    end

    it "updates existing booking" do
      booking = FactoryGirl.create(:booking, meetup_id: 12345678, chalkler: chalkler, lesson: lesson, guests: 20)
      Booking.create_from_meetup_hash result
      booking.reload.guests.should == 1
    end

    it "saves valid meetup_data" do
      Booking.create_from_meetup_hash result
      booking = Booking.find_by_meetup_id 12345678
      booking.meetup_data["rsvp_id"].should == 12345678
      booking.meetup_data["member"]["member_id"].should == 12345678
    end

    pending "won't update past classes" do
      booking = FactoryGirl.create(:booking, meetup_id: 12345678, chalkler: chalkler, lesson: lesson, guests: 20)
      booking.start_at = Chronic.parse("a year ago")
      booking.save
      Booking.create_from_meetup_hash result
      booking.reload.guests.should == 20
    end

    pending "won't update after 7pm on the eve of a class" do
      start_at = Chronic.parse "yesterday at "
      booking = FactoryGirl.create(:booking, meetup_id: 12345678, chalkler: chalkler, lesson: lesson, guests: 20)
      Booking.create_from_meetup_hash result
      booking.reload.guests.should == 1
    end
  end

  describe "#set_from_meetup_data" do
    let(:result) { MeetupApiStub::rsvp_response }

    before do
      FactoryGirl.create(:chalkler, meetup_id: 12345678)
      FactoryGirl.create(:lesson, meetup_id: 12345678)
      Booking.create_from_meetup_hash result
      @booking = Booking.find_by_meetup_id 12345678
    end

    it "saves correct created_at value" do
      @booking.created_at.to_time.to_i.should == 1351297791
    end

    it "saves correct updated_at value" do
      @booking.updated_at.to_time.to_i.should == 1351297791
    end
  end

  let(:booking) { FactoryGirl.create(:booking) }

  describe ".visible" do
    it {Booking.visible.should include(booking)}

    it "should not include invisible booking" do
      booking.visible = false
      booking.save
      Booking.visible.should_not include(booking)
    end
  end

  describe ".hidden" do
    it "includes hidden bookings" do
      booking.visible = false
      booking.save
      Booking.hidden.should include(booking)
    end

    it {Booking.hidden.should_not include(booking)}
  end

end
