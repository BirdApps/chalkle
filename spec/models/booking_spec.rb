require 'spec_helper'

describe Booking do
  it { should belong_to(:lesson) }
  it { should belong_to(:chalkler) }
  it { should have_one(:payment) }

  it { should validate_presence_of(:lesson_id) }
  it { should validate_presence_of(:chalkler_id) }
  it { should validate_uniqueness_of(:chalkler_id) }

  describe "#cost" do
    subject { booking }

    context "lesson has no cost" do
      let(:lesson) { FactoryGirl.create(:lesson, cost: nil) }
      let(:booking) { FactoryGirl.create(:booking, guests: 0, lesson: lesson) }
      specify { subject.cost.should be_nil }
    end

    context "lesson has no guests" do
      let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
      let(:booking) { FactoryGirl.create(:booking, guests: 0, lesson: lesson) }
      specify { subject.cost.should == 10 }
    end

    context "lesson has cost and booking has no guests" do
      let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
      let(:booking) { FactoryGirl.create(:booking, guests: nil, lesson: lesson) }
      specify { subject.cost.to_f.should == 10 }
    end

    context "lesson has cost and booking has guests" do
      let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
      let(:booking) { FactoryGirl.create(:booking, guests: 9, lesson: lesson) }
      specify { subject.cost.to_f.should == 100 }
    end
  end

  describe ".paid" do
    context "excludes unpaid bookings" do
      let(:booking) { FactoryGirl.create(:booking, paid: nil) }
      it { Booking.paid.should_not include(booking) }
    end

    context "includes paid bookings" do
      let(:booking) { FactoryGirl.create(:booking, paid: true) }
      it { Booking.paid.should include(booking) }
    end
  end

  describe ".unpaid" do
    context "excludes paid bookings" do
      let(:booking) { FactoryGirl.create(:booking, paid: true) }
      it { Booking.unpaid.should_not include(booking) }
    end

    context "includes unpaid bookings" do
      let(:booking) { FactoryGirl.create(:booking, paid: nil) }
      it { Booking.unpaid.should include(booking) }
    end
  end

  describe ".confirmed" do
    context "excludes unconfirmed bookings" do
      let(:booking) { FactoryGirl.create(:booking, status: "waitlist") }
      it { Booking.confirmed.should_not include(booking) }
    end

    context "includes confirmed bookings" do
      let(:booking) { FactoryGirl.create(:booking, status: "yes") }
      it { Booking.confirmed.should include(booking) }
    end
  end

  describe ".waitlist" do
    context "excludes confirmed bookings" do
      let(:booking) { FactoryGirl.create(:booking, status: "yes") }
      it { Booking.waitlist.should_not include(booking) }
    end

    context "includes waitlisted bookings" do
      let(:booking) { FactoryGirl.create(:booking, status: "waitlist") }
      it { Booking.waitlist.should include(booking) }
    end
  end

  describe ".billable" do
    context "excludes bookings with a zero cost" do
      let(:lesson) { FactoryGirl.create(:lesson, cost: 0) }
      let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }
      it { Booking.billable.should_not include(booking) }
    end

    context "includes bookings that have a cost" do
      let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
      let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }
      it { Booking.billable.should include(booking) }
    end
  end

  describe "#name" do
    subject { booking }
    context "creates name when lesson and chalkler present" do
      let(:lesson) { FactoryGirl.create(:lesson, name: "lesson_name", meetup_id: 12345678) }
      let(:chalkler) { FactoryGirl.create(:chalkler, name: "chalkler_name") }
      let(:booking) { FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler) }
      specify { subject.name.should == "lesson_name (12345678) - chalkler_name" }
    end
  end

  describe ".create_from_meetup_hash" do

    let(:result) { MeetupApiStub::Rsvp.new }
    let!(:chalkler) { FactoryGirl.create(:chalkler, meetup_id: 12345678) }
    let!(:lesson) { FactoryGirl.create(:lesson, meetup_id: 12345678) }
    let(:return_value) { Booking.create_from_meetup_hash(result) }

    context "creates a valid Booking" do
      specify { return_value.should be_true }
    end

    context "updates existing booking" do
      let!(:booking) { FactoryGirl.create(:booking, meetup_id: 987654, chalkler: chalkler, lesson: lesson) }

      before do
        booking.save
        Booking.create_from_meetup_hash result
      end

      pending { booking.meetup_id.should == 12345678 }
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
