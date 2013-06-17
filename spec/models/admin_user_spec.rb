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
    context "super admin user" do
      subject { ability }
      let(:ability){ Ability.new(admin_user) }
      let(:admin_user){ FactoryGirl.create(:super_admin_user) }

      it { should be_able_to(:manage, FactoryGirl.create(:admin_user)) }
      it { should be_able_to(:manage, FactoryGirl.create(:channel)) }

      it { should be_able_to(:read, FactoryGirl.create(:chalkler)) }
      it { should be_able_to(:create, FactoryGirl.create(:chalkler)) }
      it { should be_able_to(:update, FactoryGirl.create(:chalkler)) }

      it { should be_able_to(:read, FactoryGirl.create(:booking)) }
      it { should be_able_to(:create, FactoryGirl.create(:booking)) }
      it { should be_able_to(:update, FactoryGirl.create(:booking)) }
      it { should be_able_to(:hide, FactoryGirl.create(:booking)) }
      it { should be_able_to(:unhide, FactoryGirl.create(:booking)) }

      it { should be_able_to(:read, FactoryGirl.create(:lesson)) }
      it { should be_able_to(:update, FactoryGirl.create(:lesson)) }
      it { should be_able_to(:hide, FactoryGirl.create(:lesson)) }
      it { should be_able_to(:unhide, FactoryGirl.create(:lesson)) }

      it { should be_able_to(:read, FactoryGirl.create(:payment)) }
      it { should be_able_to(:create, FactoryGirl.create(:payment)) }
      it { should be_able_to(:update, FactoryGirl.create(:payment)) }
      it { should be_able_to(:hide, FactoryGirl.create(:payment)) }
      it { should be_able_to(:unhide, FactoryGirl.create(:payment)) }
      it { should be_able_to(:reconcile, FactoryGirl.create(:payment)) }
      it { should be_able_to(:do_reconcile, FactoryGirl.create(:payment)) }
      it { should be_able_to(:download_from_xero, FactoryGirl.create(:payment)) }

      it { should be_able_to(:manage, FactoryGirl.create(:category)) }
    end

    context "channel admin user" do
      before do
        @channel = FactoryGirl.create(:channel)
        @admin_user = FactoryGirl.create(:channel_admin_user)
        @admin_user.channels << @channel
      end

      it "should be able to administrate lessons" do
        lesson = FactoryGirl.create(:lesson)
        lesson.channels << @channel
        ability = Ability.new @admin_user
        ability.should be_able_to(:read, lesson)
        ability.should be_able_to(:update, lesson)
      end

      it "should not be able to administrate channels" do
        ability = Ability.new @admin_user
        ability.should_not be_able_to(:view, @channel)
        ability.should_not be_able_to(:update, @channel)
        ability.should_not be_able_to(:destroy, @channel)
      end

      it "should not be able to administrate admin users" do
        ability = Ability.new @admin_user
        admin_user_2 = FactoryGirl.create(:admin_user)
        ability.should_not be_able_to(:view, admin_user_2)
        ability.should_not be_able_to(:update, admin_user_2)
        ability.should_not be_able_to(:destroy, admin_user_2)
      end

      it "should be able to administrate bookings" do
        lesson = FactoryGirl.create(:lesson)
        booking = FactoryGirl.create(:booking, lesson: lesson)
        lesson.channels << @channel
        ability = Ability.new @admin_user
        ability.should be_able_to(:read, booking)
        ability.should be_able_to(:update, booking)
        ability.should_not be_able_to(:destroy, booking)
      end

      it "should not be able to administrate payments" do
        payment = FactoryGirl.create(:payment)
        ability = Ability.new @admin_user
        ability.should_not be_able_to(:view, payment)
      end
    end
  end
end
