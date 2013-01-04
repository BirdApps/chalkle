require 'spec_helper'
require 'cancan/matchers'

describe AdminUser do
  it { should have_many(:groups).through(:group_admins) }
  it { should have_many(:lessons).through(:groups) }
  it { should have_many(:chalklers).through(:groups) }
  it { should have_many(:bookings).through(:groups) }
  it { should have_many(:categories).through(:groups) }
  it { should have_many(:payments).through(:bookings) }

  describe "abilities" do
    subject { ability }
    let(:ability){ Ability.new(admin_user) }

    context "when is an super admin user" do
      let(:admin_user){ FactoryGirl.create(:super_admin_user) }

      it { should be_able_to(:manage, FactoryGirl.create(:admin_user, email: "user@example.com")) }
      it { should be_able_to(:manage, FactoryGirl.create(:group)) }

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

    context "when is a group admin user" do
      let(:group){ FactoryGirl.create(:group) }
      let(:admin_user){ FactoryGirl.create(:group_admin_user, groups: [group]) }

      it { should_not be_able_to(:manage, FactoryGirl.create(:group)) }
      it { should_not be_able_to(:manage, FactoryGirl.create(:admin_user, email: "user@example.com")) }

      context "and resource shares group" do
        it { should be_able_to(:read, FactoryGirl.create(:chalkler, groups: [group])) }
        it { should be_able_to(:update, FactoryGirl.create(:chalkler, groups: [group])) }
        it { should be_able_to(:create, FactoryGirl.create(:chalkler)) }

        it { should be_able_to(:read, FactoryGirl.create(:lesson, groups: [group])) }
        it { should be_able_to(:update, FactoryGirl.create(:lesson, groups: [group])) }
        it { should be_able_to(:hide, FactoryGirl.create(:lesson, groups: [group])) }
        it { should be_able_to(:unhide, FactoryGirl.create(:lesson, groups: [group])) }

        it { should be_able_to(:read, FactoryGirl.create(:payment)) }
        it { should be_able_to(:create, FactoryGirl.create(:payment)) }
        it { should be_able_to(:update, FactoryGirl.create(:payment)) }
        it { should be_able_to(:hide, FactoryGirl.create(:payment)) }
        it { should be_able_to(:unhide, FactoryGirl.create(:payment)) }
        it { should be_able_to(:reconcile, FactoryGirl.create(:payment)) }
        it { should be_able_to(:do_reconcile, FactoryGirl.create(:payment)) }
        it { should be_able_to(:download_from_xero, FactoryGirl.create(:payment)) }

        it { should be_able_to(:manage, FactoryGirl.create(:category)) }

        it "should be able to read bookings" do
          lesson = FactoryGirl.create(:lesson, groups: [group])
          should be_able_to(:read, FactoryGirl.create(:booking, lesson: lesson))
        end

        it "should be able to update bookings" do
          lesson = FactoryGirl.create(:lesson, groups: [group])
          should be_able_to(:update, FactoryGirl.create(:booking, lesson: lesson))
        end

        it "should be able to hide bookings" do
          lesson = FactoryGirl.create(:lesson, groups: [group])
          should be_able_to(:hide, FactoryGirl.create(:booking, lesson: lesson))
        end

        it "should be able to unhide bookings" do
          lesson = FactoryGirl.create(:lesson, groups: [group])
          should be_able_to(:unhide, FactoryGirl.create(:booking, lesson: lesson))
        end

        it { should be_able_to(:create, FactoryGirl.create(:booking)) }
      end
    end
  end
end
