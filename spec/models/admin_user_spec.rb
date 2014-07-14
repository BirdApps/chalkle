require 'spec_helper'
require 'cancan/matchers'

describe AdminUser do
  it { should have_many(:channels).through(:channel_admins) }
  it { should have_many(:courses).through(:channels) }
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


      it { expect(ability).to be_able_to(:manage, AdminUser.new) }
      it { expect(ability).to be_able_to(:manage, Channel.new) }

      it { expect(ability).to be_able_to(:read, Chalkler.new) }
      it { expect(ability).to be_able_to(:create, Chalkler.new) }
      it { expect(ability).to be_able_to(:update, Chalkler.new) }
      it { expect(ability).to be_able_to(:send_reset_password_mail, Chalkler.new) }

      it { expect(ability).to be_able_to(:read, Booking.new) }
      it { expect(ability).to be_able_to(:create, Booking.new) }
      it { expect(ability).to be_able_to(:update, Booking.new) }
      it { expect(ability).to be_able_to(:hide, Booking.new) }
      it { expect(ability).to be_able_to(:unhide, Booking.new) }
      it { expect(ability).to be_able_to(:record_cash_payment, Booking.new) }

      it { expect(ability).to be_able_to(:read, Course.new) }
      it { expect(ability).to be_able_to(:update, Course.new) }
      it { expect(ability).to be_able_to(:hide, Course.new) }
      it { expect(ability).to be_able_to(:unhide, Course.new) }
      it { expect(ability).to be_able_to(:course_email, Course.new) }
      it { expect(ability).to be_able_to(:payment_summary_email, Course.new) }
      it { expect(ability).to be_able_to(:meetup_template, Course.new) }
      it { expect(ability).to be_able_to(:copy_course, Course.new) }

      it { expect(ability).to be_able_to(:read, Payment.new) }
      it { expect(ability).to be_able_to(:create, Payment.new) }
      it { expect(ability).to be_able_to(:update, Payment.new) }
      it { expect(ability).to be_able_to(:hide, Payment.new) }
      it { expect(ability).to be_able_to(:unhide, Payment.new) }
      it { expect(ability).to be_able_to(:reconcile, Payment.new) }
      it { expect(ability).to be_able_to(:unreconcile, Payment.new) }
      it { expect(ability).to be_able_to(:do_reconcile, Payment.new) }
      it { expect(ability).to be_able_to(:download_from_xero, Payment.new) }

      it { expect(ability).to be_able_to(:manage, Category.new) }

      it { expect(ability).to be_able_to(:manage, CourseSuggestion.new) }

      it { expect(ability).to be_able_to(:read, CourseImage.new) }
      it { expect(ability).to be_able_to(:create, CourseImage.new) }
      it { expect(ability).to be_able_to(:update, CourseImage.new) }
    end

    context "channel admin user" do
      let(:channel) { FactoryGirl.create(:channel) }
      let(:admin_user) do
        admin_user = FactoryGirl.create(:channel_admin_user)
        admin_user.channels << channel
        admin_user
      end

      it { expect(ability).to be_able_to(:create, Chalkler.new) }

      it "can administrate chalklers" do
        chalkler = FactoryGirl.create(:chalkler)
        chalkler.channels << channel
        expect(subject).to be_able_to(:read, chalkler)
        expect(subject).to be_able_to(:update, chalkler)
        expect(subject).to be_able_to(:send_reset_password_mail, chalkler)
      end

      it { expect(subject).to be_able_to(:manage, CourseSuggestion.new) }

      it { expect(subject).to be_able_to(:read, CourseImage.new) }
      it { expect(subject).to be_able_to(:create, CourseImage.new) }
      it { expect(subject).to be_able_to(:update, CourseImage.new) }

      it "should be able to administrate courses" do
        course = FactoryGirl.create(:course, channel: channel)
        expect(subject).to be_able_to(:read, course)
        expect(subject).to be_able_to(:update, course)
        expect(subject).to be_able_to(:meetup_template, course)
        expect(subject).to be_able_to(:copy_course, course)
        expect(subject).to be_able_to(:hide, course)
        expect(subject).to be_able_to(:unhide, course)
      end

      it "should be able to view channels" do
        expect(subject).to be_able_to(:read, channel)
      end

      it "should not be able to administrate channels" do
        expect(subject).not_to be_able_to(:update, channel)
        expect(subject).not_to be_able_to(:destroy, channel)
      end

      it "should not be able to administrate admin users" do
        admin_user_2 = FactoryGirl.create(:admin_user)
        expect(subject).not_to be_able_to(:view, admin_user_2)
        expect(subject).not_to be_able_to(:update, admin_user_2)
        expect(subject).not_to be_able_to(:destroy, admin_user_2)
      end

      it "should be able to administrate bookings" do

        course = FactoryGirl.create(:course, channel: channel)
        booking = FactoryGirl.create(:booking, course: course)
        expect(subject).to be_able_to(:read, booking)
        expect(subject).to be_able_to(:create, booking)
        expect(subject).to be_able_to(:update, booking)
        expect(subject).to be_able_to(:record_cash_payment, booking)
      end

      it "should not be able to delete bookings" do
        course = FactoryGirl.create(:course, channel: channel)
        booking = FactoryGirl.create(:booking, course: course)
        expect(subject).not_to be_able_to(:destroy, booking)
      end

      it "should not be able to administrate payments" do
        payment = FactoryGirl.create(:payment)
        expect(subject).not_to be_able_to(:view, payment)
      end
    end
  end

  describe "#super?" do
    let(:user) { AdminUser.new }

    it "is true if the admin is a super user" do
      expect(user.super?).to be false
    end

    it "is true if the admin is a super user" do
      user.role = "super"
      expect(user.super?).to be true
    end
  end

  describe "#super!" do
    it "changes the admin user to a super admin user" do
      user = AdminUser.new
      expect(user).to receive(:save) { true }
      user.super!
      expect(user.super?).to be true
    end
  end
end
