require 'spec_helper'

describe Booking do
  describe "resource creation" do
    specify { FactoryGirl.build(:booking).should be_valid }

    it { should validate_presence_of(:course_id) }
    it { should validate_presence_of(:chalkler_id) }
    it { should validate_presence_of(:payment_method) }

    it "should validate chalkler + course uniqueness" do
      chalkler = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course)
      FactoryGirl.create(:booking, chalkler: chalkler, course: course)
      FactoryGirl.build(:booking, chalkler: chalkler, course: course).should_not be_valid
    end

    describe "callbacks" do

      describe "#set_free_course_attributes" do
        context "free course" do
          let(:course) { FactoryGirl.create(:course, cost: 0) }
          let(:booking) { FactoryGirl.create(:booking, course: course) }

          it "sets payment method to free" do
            booking.payment_method.should == 'free'
          end

          it "sets paid to true" do
            booking.paid.should be_true
          end
        end

        context "paid course" do
          let(:course) { FactoryGirl.create(:course, cost: 10) }
          let(:booking) { FactoryGirl.create(:booking, course: course) }

          it "leaves booking untouched" do
            booking.payment_method.should_not == 'free'
            booking.paid.should be_false
          end
        end

        context "course with no price" do
          let(:course) { FactoryGirl.create(:course, cost: nil) }
          let(:booking) { FactoryGirl.create(:booking, course: course) }

          it "leaves booking untouched" do
            booking.payment_method.should_not == 'free'
            booking.paid.should be_false
          end
        end
      end
    end
  end

  describe "#cost" do
    it "returns nil when course has no cost" do
      course = FactoryGirl.create(:course, cost: nil)
      booking = FactoryGirl.create(:booking, guests: 5, cost_override: nil, course: course)
      booking.cost.should be_nil
    end

    it "returns cost from course" do
      course = FactoryGirl.create(:course, cost: 10)
      booking = FactoryGirl.create(:booking, guests: 0, cost_override: nil, course: course)
      booking.cost.to_f.should == 10
    end

    it "calculates cost when booking has no guests" do
      course = FactoryGirl.create(:course, cost: 10)
      booking = FactoryGirl.create(:booking, guests: nil, cost_override: nil, course: course)
      booking.cost.to_f.should == 10
    end

    it "calculates cost when booking has guests" do
      course = FactoryGirl.create(:course, cost: 10)
      booking =  FactoryGirl.create(:booking, guests: 9, cost_override: nil, course: course)
      booking.cost.to_f.should == 100
    end

    it "sets a correct cost_override" do
      course = FactoryGirl.create(:course, cost: 10)
      booking =  FactoryGirl.create(:booking, cost_override: 20, course: course)
      booking.cost.to_f.should == 20
    end
  end

  describe ".paid" do
    it "excludes unpaid bookings" do
      booking = FactoryGirl.create(:booking)
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
      booking = FactoryGirl.create(:booking)
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
      course = FactoryGirl.create(:course, cost: 0)
      booking = FactoryGirl.create(:booking, course: course)
      Booking.billable.should_not include(booking)
    end

    it "includes bookings that have a cost" do
      course = FactoryGirl.create(:course, cost: 10)
      booking = FactoryGirl.create(:booking, course: course)
      Booking.billable.should include(booking)
    end

    context "booking belongs to the teacher" do
      let(:teacher) { FactoryGirl.create(:chalkler, email: "example@testy.com")}
      let(:course) { FactoryGirl.create(:course, teacher: teacher, cost: 10) }

      it "is included with guests" do
        booking = FactoryGirl.create(:booking, course: course, chalkler: teacher, guests: 1)
        Booking.billable.should include(booking)
      end

      it "is excluded without guests" do
        booking = FactoryGirl.create(:booking, course: course, chalkler: teacher, guests: nil)
        Booking.billable.should_not include(booking)
      end
    end
  end

  describe ".upcoming" do
    it "includes booking for courses in the future" do
      course = FactoryGirl.create(:course, start_at: 2.days.from_now, visible: true)
      booking = FactoryGirl.create(:booking, course: course)
      Booking.upcoming.should include(booking)
    end

    it "excludes bookings for courses in the past" do
      lessons = [FactoryGirl.create(:lesson, start_at: 2.days.ago)]
      course = FactoryGirl.create(:course, lessons: lessons, visible: true)
      booking = FactoryGirl.create(:booking, course: course)
      Booking.upcoming.should_not include(booking)
    end

    it "excludes bookings for cancelled courses" do
      lessons = [FactoryGirl.create(:lesson, start_at: 2.days.from_now)]
      course = FactoryGirl.create(:course, lessons: lessons, visible: false)
      booking = FactoryGirl.create(:booking, course: course)
      Booking.upcoming.should_not include(booking)
    end
  end

  describe "#name" do
    it "creates name when course and chalkler present" do
      course = FactoryGirl.create(:course, name: "course_name", meetup_id: 12345678)
      chalkler = FactoryGirl.create(:chalkler, name: "chalkler_name")
      booking = FactoryGirl.create(:booking, course: course, chalkler: chalkler)
      booking.name.should == "course_name (12345678) - chalkler_name"
    end
  end

  let(:booking) { FactoryGirl.create(:booking) }

  describe ".visible" do
    it {Booking.visible.should include(booking)}

    it "should not include a hidden booking" do
      booking.update_attribute :visible, false
      Booking.visible.should_not include(booking)
    end
  end

  describe ".hidden" do
    it "includes hidden bookings" do
      booking.update_attribute :visible, false
      Booking.hidden.should include(booking)
    end

    it {Booking.hidden.should_not include(booking)}
  end

  describe "#refundable?" do
    it "returns false when course is less than 3 days away" do
      lessons = [FactoryGirl.create(:lesson, start_at: 2.days.from_now)]
      course = FactoryGirl.create(:course, lessons: lessons)
      FactoryGirl.build(:booking, course: course).refundable?.should be_false
    end

    it "returns true when course is more than 3 days away" do
      lessons = [FactoryGirl.create(:lesson, start_at: 4.days.from_now)]
      course = FactoryGirl.create(:course, lessons: lessons)
      FactoryGirl.build(:booking, course: course).refundable?.should be_true
    end
  end

  describe "#teacher?" do
    it "returns false when course has no teacher" do
      course = FactoryGirl.create(:course, teacher_id: nil)
      FactoryGirl.build(:booking, course: course).teacher?.should be_false
    end

    it "returns true when chalkler is teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course, teacher: chalkler)
      FactoryGirl.build(:booking, course: course, chalkler: chalkler).teacher?.should be_true
    end

    it "returns false when chalkler isn't a teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      teacher = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course, teacher: teacher)
      FactoryGirl.build(:booking, course: course, chalkler: chalkler).teacher?.should be_false
    end
  end

  describe "#cancelled?" do
    it "reurns true if booking is cancelled" do
      FactoryGirl.build(:booking, status: 'no').cancelled?.should be_true
    end

    it "returns false if booking is not cancelled" do
      FactoryGirl.build(:booking, status: 'yes').cancelled?.should be_false
    end
  end
end

  # describe "reminder to pay emails" do
    # pending "never email teachers" do
      # booking.chalkler_id = booking.course.teacher_id
      # booking.save
      # booking.emailable.should be_false
    # end

    # pending "never email free classes" do
      # course = FactoryGirl.create(:course, cost: 0)
      # booking =  FactoryGirl.create(:booking, course: course)
      # booking.emailable.should be_false
    # end

    # pending "never email free bookings" do
      # booking.cost_override = 0
      # booking.save
      # booking.emailable.should be_false
    # end

    # pending "never email booking status of no" do
      # booking.status = 'no'
      # booking.save
      # booking.emailable.should be_false
    # end

    # pending "never email booking status of waitlist" do
      # booking.status = 'waitlist'
      # booking.save
      # booking.emailable.should be_false
    # end

    # pending "never email paid bookings" do
      # booking.paid = true
      # booking.save
      # booking.emailable.should be_false
    # end
  # end

  # describe "first reminder to pay email" do
    # let(:course) { FactoryGirl.create(:course, cost: 10, teacher_id: 123, start_at: Date.today + 10) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, course: course, chalkler: chalkler, paid: false, status: 'yes') }

    # pending "send to new bookings" do
      # booking.first_email_condition.should be_true
    # end

    # pending "not send to new bookings with courses in the next three days" do
      # course.start_at = Date.today + 1
      # booking.first_email_condition.should be_false
    # end
  # end

  # describe "second reminder to pay email" do
    # let(:course) { FactoryGirl.create(:course, cost: 10, teacher_id: 123, start_at: Date.today + 10) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, course: course, chalkler: chalkler, paid: nil, status: 'yes') }

    # pending "not send to new bookings with courses more than three days away" do
      # booking.second_email_condition.should be_false
    # end

    # pending "send to new bookings with courses in the next three days" do
      # course.start_at = Date.today + 3
      # booking.second_email_condition.should be_true
    # end
  # end

  # describe "third reminder to pay email" do
    # let(:course) { FactoryGirl.create(:course, cost: 10, teacher_id: 123, start_at: Date.today + 3) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, course: course, chalkler: chalkler, paid: nil, status: 'waitlist') }

    # pending "send to those on waitlist" do
      # booking.third_email_condition.should be_true
    # end

    # pending "do not send to yes" do
      # booking.status = 'yes'
      # booking.save
      # booking.third_email_condition.should be_false
    # end
  # end

  # describe "reminder to pay after class email" do
    # let(:course) { FactoryGirl.create(:course, cost: 10, teacher_id: 123, start_at: Date.today - 3) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, course: course, chalkler: chalkler, paid: nil, status: 'yes') }

    # pending "send to booking still unpaid" do
      # booking.reminder_after_class_condition.should be_true
    # end
  # end

  # describe "no show email" do
    # let(:course) { FactoryGirl.create(:course, cost: 10, teacher_id: 123, start_at: Date.today - 3) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, course: course, chalkler: chalkler, paid: nil, status: 'no-show') }

    # pending "send to bookings marked as no-show" do
      # booking.no_show_email_condition.should be_true
    # end

    # pending "do not send to booking not marked as no-show" do
      # booking.status = 'yes'
      # booking.save
      # booking.no_show_email_condition.should be_false
    # end

    # pending "do not send to paid booking" do
      # booking.paid = true
      # booking.save
      # booking.no_show_email_condition.should be_false
    # end

    # pending "do not send to future classes" do
      # course.start_at = Date.today + 3
      # course.save
      # booking.no_show_email_condition.should be_false
    # end
  # end
# end

