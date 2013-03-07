require 'spec_helper'

describe Channel do
  it { should have_many(:admin_users).through(:channel_admins) }
  it { should have_many(:chalklers).through(:channel_chalklers) }
  it { should have_many(:lessons).through(:channel_lessons) }
  it { should have_many(:bookings).through(:lessons) }
  it { should have_many(:categories).through(:channel_categories) }

  it { should validate_presence_of :name }

  describe "email validations" do
    it "should not allow email without @" do
    	channel = Channel.create(name: "test", email: "abs123")
    	channel.should_not be_valid
    end

    it "should not allow with @ but no ." do
    	channel = Channel.create(name: "test", email: "abs@123")
    	channel.should_not be_valid
    end
  end
end
