require 'spec_helper'

describe Booking do
  describe "resource creation" do
    specify { FactoryGirl.build(:booking).should be_valid }

    it { should validate_presence_of(:lesson_id) }
    it { should validate_presence_of(:chalkler_id) }
    it { should validate_presence_of(:payment_method) }

    it "should validate chalkler + lesson uniqueness" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson)
      FactoryGirl.create(:booking, chalkler: chalkler, lesson: lesson)
      FactoryGirl.build(:booking, chalkler: chalkler, lesson: lesson).should_not be_valid
    end

    describe "callbacks" do

      describe "#set_free_lesson_attributes" do
        context "free lesson" do
          let(:lesson) { FactoryGirl.create(:lesson, cost: 0) }
          let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }

          it "sets payment method to free" do
            booking.payment_method.should == 'free'
          end

          it "sets paid to true" do
            booking.paid.should be_true
          end
        end

        context "paid lesson" do
          let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
          let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }

          it "leaves booking untouched" do
            booking.payment_method.should_not == 'free'
            booking.paid.should be_false
          end
        end

        context "lesson with no price" do
          let(:lesson) { FactoryGirl.create(:lesson, cost: nil) }
          let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }

          it "leaves booking untouched" do
            booking.payment_method.should_not == 'free'
            booking.paid.should be_false
          end
        end
      end
    end
  end

  describe "#cost" do
    it "returns nil when lesson has no cost" do
      lesson = FactoryGirl.create(:lesson, cost: nil)
      booking = FactoryGirl.create(:booking, guests: 5, cost_override: nil, lesson: lesson)
      booking.cost.should be_nil
    end

    it "returns cost from lesson" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, guests: 0, cost_override: nil, lesson: lesson)
      booking.cost.to_f.should == 10
    end

    it "calculates cost when booking has no guests" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, guests: nil, cost_override: nil, lesson: lesson)
      booking.cost.to_f.should == 10
    end

    it "calculates cost when booking has guests" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking =  FactoryGirl.create(:booking, guests: 9, cost_override: nil, lesson: lesson)
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
      let(:teacher) { FactoryGirl.create(:chalkler, email: "example@testy.com", uid: '1234')}
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

  describe ".upcoming" do
    it "includes booking for lessons in the future" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, visible: true)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      Booking.upcoming.should include(booking)
    end

    it "excludes bookings for lessons in the past" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago, visible: true)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      Booking.upcoming.should_not include(booking)
    end

    it "excludes bookings for cancelled lessons" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, visible: false)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      Booking.upcoming.should_not include(booking)
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
    it "returns false when lesson is less than 3 days away" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now)
      FactoryGirl.build(:booking, lesson: lesson).refundable?.should be_false
    end

    it "returns true when lesson is more than 3 days away" do
      lesson = FactoryGirl.create(:lesson, start_at: 4.days.from_now)
      FactoryGirl.build(:booking, lesson: lesson).refundable?.should be_true
    end
  end

  describe "#teacher?" do
    it "returns false when lesson has no teacher" do
      lesson = FactoryGirl.create(:lesson, teacher_id: nil)
      FactoryGirl.build(:booking, lesson: lesson).teacher?.should be_false
    end

    it "returns true when chalkler is teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson, teacher: chalkler)
      FactoryGirl.build(:booking, lesson: lesson, chalkler: chalkler).teacher?.should be_true
    end

    it "returns false when chalkler isn't a teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      teacher = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson, teacher: teacher)
      FactoryGirl.build(:booking, lesson: lesson, chalkler: chalkler).teacher?.should be_false
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
      # booking.chalkler_id = booking.lesson.teacher_id
      # booking.save
      # booking.emailable.should be_false
    # end

    # pending "never email free classes" do
      # lesson = FactoryGirl.create(:lesson, cost: 0)
      # booking =  FactoryGirl.create(:booking, lesson: lesson)
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
    # let(:lesson) { FactoryGirl.create(:lesson, cost: 10, teacher_id: 123, start_at: Date.today + 10) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler, paid: false, status: 'yes') }

    # pending "send to new bookings" do
      # booking.first_email_condition.should be_true
    # end

    # pending "not send to new bookings with lessons in the next three days" do
      # lesson.start_at = Date.today + 1
      # booking.first_email_condition.should be_false
    # end
  # end

  # describe "second reminder to pay email" do
    # let(:lesson) { FactoryGirl.create(:lesson, cost: 10, teacher_id: 123, start_at: Date.today + 10) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler, paid: nil, status: 'yes') }

    # pending "not send to new bookings with lessons more than three days away" do
      # booking.second_email_condition.should be_false
    # end

    # pending "send to new bookings with lessons in the next three days" do
      # lesson.start_at = Date.today + 3
      # booking.second_email_condition.should be_true
    # end
  # end

  # describe "third reminder to pay email" do
    # let(:lesson) { FactoryGirl.create(:lesson, cost: 10, teacher_id: 123, start_at: Date.today + 3) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler, paid: nil, status: 'waitlist') }

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
    # let(:lesson) { FactoryGirl.create(:lesson, cost: 10, teacher_id: 123, start_at: Date.today - 3) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler, paid: nil, status: 'yes') }

    # pending "send to booking still unpaid" do
      # booking.reminder_after_class_condition.should be_true
    # end
  # end

  # describe "no show email" do
    # let(:lesson) { FactoryGirl.create(:lesson, cost: 10, teacher_id: 123, start_at: Date.today - 3) }
    # let(:chalkler) { FactoryGirl.create(:chalkler) }
    # let(:booking) { FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler, paid: nil, status: 'no-show') }

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
      # lesson.start_at = Date.today + 3
      # lesson.save
      # booking.no_show_email_condition.should be_false
    # end
  # end
# end

