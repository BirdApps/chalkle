require 'spec_helper'

describe Booking do
  describe "resource creation" do
    specify { expect(FactoryGirl.build(:booking)).to be_valid }

    it { should validate_presence_of(:course_id) }
    it { should validate_presence_of(:chalkler_id) }
    it { should validate_presence_of(:payment_method) }

    it "should validate chalkler + course uniqueness" do
      chalkler = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course)
      FactoryGirl.create(:booking, chalkler: chalkler, course: course)
      expect(FactoryGirl.build(:booking, chalkler: chalkler, course: course)).not_to be_valid
    end

    describe "callbacks" do

      describe "#set_free_course_attributes" do
        context "free course" do
          let(:course) { FactoryGirl.create(:course, cost: 0) }
          let(:booking) { FactoryGirl.create(:booking, course: course) }

          it "sets payment method to free" do
            expect(booking.payment_method).to eq 'free'
          end

          it "sets paid to true" do
            expect(booking.paid).to be true
          end
        end

        context "paid course" do
          let(:course) { FactoryGirl.create(:course, cost: 10) }
          let(:booking) { FactoryGirl.create(:booking, course: course) }

          it "leaves booking untouched" do
            expect(booking.payment_method).not_to eq 'free'
            expect(booking.paid).to be_falsey
          end
        end

        context "course with no price" do
          let(:course) { FactoryGirl.create(:course, cost: nil) }
          let(:booking) { FactoryGirl.create(:booking, course: course) }

          it "leaves booking untouched" do
            expect(booking.payment_method).not_to eq 'free'
            expect(booking.paid).to be_falsey
          end
        end
      end
    end
  end

  describe "#cost" do

    it "returns nil when course has no cost" do
      course = FactoryGirl.create(:course, cost: nil)
      booking = FactoryGirl.create(:booking, guests: 5, cost_override: nil, course: course)
      expect(booking.cost).to be nil
    end

    it "returns cost from course" do
      course = FactoryGirl.create(:course, cost: 10)
      booking = FactoryGirl.create(:booking, guests: 0, cost_override: nil, course: course)
      expect(booking.cost.to_f).to eq 10
    end

    it "calculates cost when booking has no guests" do
      course = FactoryGirl.create(:course, cost: 10)
      booking = FactoryGirl.create(:booking, guests: nil, cost_override: nil, course: course)
      expect(booking.cost.to_f).to eq 10
    end

    it "calculates cost when booking has guests" do
      course = FactoryGirl.create(:course, cost: 10)
      booking =  FactoryGirl.create(:booking, guests: 9, cost_override: nil, course: course)
      expect(booking.cost.to_f).to eq 100
    end

    it "sets a correct cost_override" do
      course = FactoryGirl.create(:course, cost: 10)
      booking =  FactoryGirl.create(:booking, cost_override: 20, course: course)
      expect(booking.cost.to_f).to eq 20

    end
  end

  describe ".paid" do
    it "excludes unpaid bookings" do
      booking = FactoryGirl.create(:booking)
      expect(Booking.paid).not_to include(booking)
    end

    it "includes paid bookings" do
      booking = FactoryGirl.create(:booking, paid: true)
      expect(Booking.paid).to include(booking)
    end
  end

  describe ".unpaid" do
    it "excludes paid bookings" do
      booking = FactoryGirl.create(:booking, paid: true)
      expect(Booking.unpaid).not_to include(booking)
    end

    it "includes unpaid bookings" do
      booking = FactoryGirl.create(:booking)
      expect(Booking.unpaid).to include(booking)
    end
  end

  describe ".confirmed" do
    it "excludes unconfirmed bookings" do
      booking = FactoryGirl.create(:booking, status: "waitlist")
      expect(Booking.confirmed).not_to include(booking)
    end

    it "includes confirmed bookings" do
      booking = FactoryGirl.create(:booking, status: "yes")
      expect(Booking.confirmed).to include(booking)
    end
  end

  describe ".waitlist" do
    it "excludes confirmed bookings" do
      booking = FactoryGirl.create(:booking, status: "yes")
      expect(Booking.waitlist).not_to include(booking)
    end

    it "includes waitlisted bookings" do
      booking = FactoryGirl.create(:booking, status: "waitlist")
      expect(Booking.waitlist).to include(booking)
    end
  end

  describe ".billable" do
    it "excludes bookings with a zero cost" do

      course = FactoryGirl.create(:course, cost: 0)
      booking = FactoryGirl.create(:booking, course: course)
      expect(Booking.billable).not_to include(booking)
    end

    it "includes bookings that have a cost" do
      course = FactoryGirl.create(:course, cost: 10)
      booking = FactoryGirl.create(:booking, course: course)
      expect(Booking.billable).to include(booking)

    end

    context "booking belongs to the teacher" do
      let(:teacher) { FactoryGirl.create(:chalkler, email: "example@testy.com")}
      let(:course) { FactoryGirl.create(:course, teacher: teacher, cost: 10) }

      it "is included with guests" do

        booking = FactoryGirl.create(:booking, course: course, chalkler: teacher, guests: 1)
        expect(Booking.billable).to include(booking)
      end

      it "is excluded without guests" do
        booking = FactoryGirl.create(:booking, course: course, chalkler: teacher, guests: nil)
        expect(Booking.billable).not_to include(booking)

      end
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
    it "creates name when course and chalkler present" do
      course = FactoryGirl.create(:course, name: "course_name", meetup_id: 12345678)
      chalkler = FactoryGirl.create(:chalkler, name: "chalkler_name")
      booking = FactoryGirl.create(:booking, course: course, chalkler: chalkler)
      expect(booking.name).to eq "course_name (12345678) - chalkler_name"
    end
  end

  let(:booking) { FactoryGirl.create(:booking) }

  describe ".visible" do
    it {expect(Booking.visible).to include(booking)}

    it "should not include a hidden booking" do
      booking.update_attribute :visible, false
      expect(Booking.visible).not_to include(booking)
    end
  end

  describe ".hidden" do
    it "includes hidden bookings" do
      booking.update_attribute :visible, false
      expect(Booking.hidden).to include(booking)
    end

    it {expect(Booking.hidden).not_to include(booking)}
  end

  describe "#refundable?" do
    it "returns false when course is less than 3 days away" do
      lessons = [FactoryGirl.create(:lesson, start_at: 2.days.from_now)]
      course = FactoryGirl.create(:course, lessons: lessons)
      expect(FactoryGirl.build(:booking, course: course).refundable?).to be false
    end

    it "returns true when course is more than 3 days away" do
      lessons = [FactoryGirl.create(:lesson, start_at: 4.days.from_now)]
      course = FactoryGirl.create(:course, lessons: lessons)
      expect(FactoryGirl.build(:booking, course: course).refundable?).to be true
    end
  end

  describe "#teacher?" do
    it "returns false when course has no teacher" do
      course = FactoryGirl.create(:course, teacher_id: nil)
      expect(FactoryGirl.build(:booking, course: course).teacher?).to be false
    end

    it "returns true when chalkler is teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course, teacher: chalkler)
      expect(FactoryGirl.build(:booking, course: course, chalkler: chalkler).teacher?).to be true
    end

    it "returns false when chalkler isn't a teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      teacher = FactoryGirl.create(:chalkler)

      course = FactoryGirl.create(:course, teacher: teacher)
      expect(FactoryGirl.build(:booking, course: course, chalkler: chalkler).teacher?).to be false
    end
  end

  describe "#cancelled?" do
    it "reurns true if booking is cancelled" do
      expect(FactoryGirl.build(:booking, status: 'no').cancelled?).to be true
    end

    it "returns false if booking is not cancelled" do
      expect(FactoryGirl.build(:booking, status: 'yes').cancelled?).to be false
    end
  end
end

