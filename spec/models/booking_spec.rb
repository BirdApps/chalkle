require 'spec_helper'

describe Booking do
  describe "resource creation" do
    specify { expect(FactoryGirl.build(:booking)).to be_valid }

    it { should validate_presence_of(:lesson_id) }
    it { should validate_presence_of(:chalkler_id) }
    it { should validate_presence_of(:payment_method) }

    it "should validate chalkler + lesson uniqueness" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson)
      FactoryGirl.create(:booking, chalkler: chalkler, lesson: lesson)
      expect(FactoryGirl.build(:booking, chalkler: chalkler, lesson: lesson)).not_to be_valid
    end

    describe "callbacks" do

      describe "#set_free_lesson_attributes" do
        context "free lesson" do
          let(:lesson) { FactoryGirl.create(:lesson, cost: 0) }
          let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }

          it "sets payment method to free" do
            expect(booking.payment_method).to eq 'free'
          end

          it "sets paid to true" do
            expect(booking.paid).to be true
          end
        end

        context "paid lesson" do
          let(:lesson) { FactoryGirl.create(:lesson, cost: 10) }
          let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }

          it "leaves booking untouched" do
            expect(booking.payment_method).not_to eq 'free'
            expect(booking.paid).to be_falsey
          end
        end

        context "lesson with no price" do
          let(:lesson) { FactoryGirl.create(:lesson, cost: nil) }
          let(:booking) { FactoryGirl.create(:booking, lesson: lesson) }

          it "leaves booking untouched" do
            expect(booking.payment_method).not_to eq 'free'
            expect(booking.paid).to be_falsey
          end
        end
      end
    end
  end

  describe "#cost" do
    it "returns nil when lesson has no cost" do
      lesson = FactoryGirl.create(:lesson, cost: nil)
      booking = FactoryGirl.create(:booking, guests: 5, cost_override: nil, lesson: lesson)
      expect(booking.cost).to be nil
    end

    it "returns cost from lesson" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, guests: 0, cost_override: nil, lesson: lesson)
      expect(booking.cost.to_f).to eq 10
    end

    it "calculates cost when booking has no guests" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, guests: nil, cost_override: nil, lesson: lesson)
      expect(booking.cost.to_f).to eq 10
    end

    it "calculates cost when booking has guests" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking =  FactoryGirl.create(:booking, guests: 9, cost_override: nil, lesson: lesson)
      expect(booking.cost.to_f).to eq 100
    end

    it "sets a correct cost_override" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking =  FactoryGirl.create(:booking, cost_override: 20, lesson: lesson)
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
      lesson = FactoryGirl.create(:lesson, cost: 0)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      expect(Booking.billable).not_to include(booking)
    end

    it "includes bookings that have a cost" do
      lesson = FactoryGirl.create(:lesson, cost: 10)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      expect(Booking.billable).to include(booking)
    end

    context "booking belongs to the teacher" do
      let(:teacher) { FactoryGirl.create(:chalkler, email: "example@testy.com")}
      let(:lesson) { FactoryGirl.create(:lesson, teacher: teacher, cost: 10) }

      it "is included with guests" do
        booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: teacher, guests: 1)
        expect(Booking.billable).to include(booking)
      end

      it "is excluded without guests" do
        booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: teacher, guests: nil)
        expect(Booking.billable).not_to include(booking)
      end
    end
  end

  describe ".upcoming" do
    it "includes booking for lessons in the future" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, visible: true)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      expect(Booking.upcoming).to include(booking)
    end

    it "excludes bookings for lessons in the past" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.ago, visible: true)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      expect(Booking.upcoming).not_to include(booking)
    end

    it "excludes bookings for cancelled lessons" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now, visible: false)
      booking = FactoryGirl.create(:booking, lesson: lesson)
      expect(Booking.upcoming).not_to include(booking)
    end
  end

  describe "#name" do
    it "creates name when lesson and chalkler present" do
      lesson = FactoryGirl.create(:lesson, name: "lesson_name", meetup_id: 12345678)
      chalkler = FactoryGirl.create(:chalkler, name: "chalkler_name")
      booking = FactoryGirl.create(:booking, lesson: lesson, chalkler: chalkler)
      expect(booking.name).to eq "lesson_name (12345678) - chalkler_name"
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
    it "returns false when lesson is less than 3 days away" do
      lesson = FactoryGirl.create(:lesson, start_at: 2.days.from_now)
      expect(FactoryGirl.build(:booking, lesson: lesson).refundable?).to be false
    end

    it "returns true when lesson is more than 3 days away" do
      lesson = FactoryGirl.create(:lesson, start_at: 4.days.from_now)
      expect(FactoryGirl.build(:booking, lesson: lesson).refundable?).to be true
    end
  end

  describe "#teacher?" do
    it "returns false when lesson has no teacher" do
      lesson = FactoryGirl.create(:lesson, teacher_id: nil)
      expect(FactoryGirl.build(:booking, lesson: lesson).teacher?).to be false
    end

    it "returns true when chalkler is teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson, teacher: chalkler)
      expect(FactoryGirl.build(:booking, lesson: lesson, chalkler: chalkler).teacher?).to be true
    end

    it "returns false when chalkler isn't a teacher" do
      chalkler = FactoryGirl.create(:chalkler)
      teacher = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson, teacher: teacher)
      expect(FactoryGirl.build(:booking, lesson: lesson, chalkler: chalkler).teacher?).to be false
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

