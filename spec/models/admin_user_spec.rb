require 'spec_helper'
require 'cancan/matchers'

describe AdminUser do
  it { should have_many(:channels).through(:channel_admins) }
  it { should have_many(:lessons).through(:channels) }
  it { should have_many(:chalklers).through(:channels) }
  it { should have_many(:bookings).through(:channels) }
  it { should have_many(:categories).through(:channels) }
  it { should have_many(:payments).through(:bookings) }

  describe "abilities" do
    subject { ability }
    let(:ability) { Ability.new(admin_user) }
    let(:admin_user) { nil }

    context "super admin user" do
      let(:admin_user){ FactoryGirl.create(:super_admin_user) }

      it { should be_able_to(:manage, AdminUser.new) }
      it { should be_able_to(:manage, Channel.new) }

      it { should be_able_to(:read, Chalkler.new) }
      it { should be_able_to(:create, Chalkler.new) }
      it { should be_able_to(:update, Chalkler.new) }
      it { should be_able_to(:send_reset_password_mail, Chalkler.new) }

      it { should be_able_to(:read, Booking.new) }
      it { should be_able_to(:create, Booking.new) }
      it { should be_able_to(:update, Booking.new) }
      it { should be_able_to(:hide, Booking.new) }
      it { should be_able_to(:unhide, Booking.new) }
      it { should be_able_to(:record_cash_payment, Booking.new) }

      it { should be_able_to(:read, Lesson.new) }
      it { should be_able_to(:update, Lesson.new) }
      it { should be_able_to(:hide, Lesson.new) }
      it { should be_able_to(:unhide, Lesson.new) }
      it { should be_able_to(:lesson_email, Lesson.new) }
      it { should be_able_to(:payment_summary_email, Lesson.new) }
      it { should be_able_to(:meetup_template, Lesson.new) }
      it { should be_able_to(:copy_lesson, Lesson.new) }

      it { should be_able_to(:read, Payment.new) }
      it { should be_able_to(:create, Payment.new) }
      it { should be_able_to(:update, Payment.new) }
      it { should be_able_to(:hide, Payment.new) }
      it { should be_able_to(:unhide, Payment.new) }
      it { should be_able_to(:reconcile, Payment.new) }
      it { should be_able_to(:unreconcile, Payment.new) }
      it { should be_able_to(:do_reconcile, Payment.new) }
      it { should be_able_to(:download_from_xero, Payment.new) }

      it { should be_able_to(:manage, Category.new) }

      it { should be_able_to(:manage, LessonSuggestion.new) }

      it { should be_able_to(:read, LessonImage.new) }
      it { should be_able_to(:create, LessonImage.new) }
      it { should be_able_to(:update, LessonImage.new) }
    end

    context "channel admin user" do
      let(:channel) { FactoryGirl.create(:channel) }
      let(:admin_user) do
        admin_user = FactoryGirl.create(:channel_admin_user)
        admin_user.channels << channel
        admin_user
      end

      it { should be_able_to(:create, Chalkler.new) }

      it "can administrate chalklers" do
        chalkler = FactoryGirl.create(:chalkler)
        chalkler.channels << channel
        subject.should be_able_to(:read, chalkler)
        subject.should be_able_to(:update, chalkler)
        subject.should be_able_to(:send_reset_password_mail, chalkler)
      end

      it { should be_able_to(:manage, LessonSuggestion.new) }

      it { should be_able_to(:read, LessonImage.new) }
      it { should be_able_to(:create, LessonImage.new) }
      it { should be_able_to(:update, LessonImage.new) }

      it "should be able to administrate lessons" do
        lesson = FactoryGirl.create(:lesson, channel: channel)
        subject.should be_able_to(:read, lesson)
        subject.should be_able_to(:update, lesson)
        subject.should be_able_to(:meetup_template, lesson)
        subject.should be_able_to(:copy_lesson, lesson)
        subject.should be_able_to(:hide, lesson)
        subject.should be_able_to(:unhide, lesson)
      end

      it "should be able to view channels" do
        subject.should be_able_to(:read, channel)
      end

      it "should not be able to administrate channels" do
        subject.should_not be_able_to(:update, channel)
        subject.should_not be_able_to(:destroy, channel)
      end

      it "should not be able to administrate admin users" do
        admin_user_2 = FactoryGirl.create(:admin_user)
        subject.should_not be_able_to(:view, admin_user_2)
        subject.should_not be_able_to(:update, admin_user_2)
        subject.should_not be_able_to(:destroy, admin_user_2)
      end

      it "should be able to administrate bookings" do
        lesson = FactoryGirl.create(:lesson, channel: channel)
        booking = FactoryGirl.create(:booking, lesson: lesson)
        subject.should be_able_to(:read, booking)
        subject.should be_able_to(:create, booking)
        subject.should be_able_to(:update, booking)
        subject.should be_able_to(:record_cash_payment, booking)
      end

      it "should not be able to delete bookings" do
        lesson = FactoryGirl.create(:lesson, channel: channel)
        booking = FactoryGirl.create(:booking, lesson: lesson)
        subject.should_not be_able_to(:destroy, booking)
      end

      it "should not be able to administrate payments" do
        payment = FactoryGirl.create(:payment)
        subject.should_not be_able_to(:view, payment)
      end
    end
  end

  describe "#super?" do
    let(:user) { AdminUser.new }

    it "is true if the admin is a super user" do
      expect(user.super?).to be_false
    end

    it "is true if the admin is a super user" do
      user.role = "super"
      expect(user.super?).to be_true
    end
  end

  describe "#super!" do
    it "changes the admin user to a super admin user" do
      user = AdminUser.new
      expect(user).to receive(:save) { true }
      user.super!
      expect(user.super?).to be_true
    end
  end
end
