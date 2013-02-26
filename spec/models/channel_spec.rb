require 'spec_helper'

describe Channel do
  it { should have_many(:admin_users).through(:channel_admins) }
  it { should have_many(:chalklers).through(:channel_chalklers) }
  it { should have_many(:lessons).through(:channel_lessons) }
  it { should have_many(:bookings).through(:lessons) }
  it { should have_many(:categories).through(:channel_categories) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url_name }

  let(:channel) { FactoryGirl.create(:channel) }

  describe "default values" do

  	it "should set default teacher percentage" do
  		channel.teacher_percentage.should == 0.8
  	end

  	it "should set default channel percentage" do
  		channel.channel_percentage.should == 0.0
  	end

  end

  describe "validation" do
  	
  	it "should not allow teacher percentage greater than 1" do
  		channel.teacher_percentage = 1.2
  		channel.should_not be_valid
  	end

  	it "should not allow channel percentage greater than 1" do
  		channel.channel_percentage = 1.2
  		channel.should_not be_valid
  	end

  	it "should not allow sum of percentages greater than 1" do
  		channel.channel_percentage = 0.8
  		channel.teacher_percentage = 0.8
  		channel.should_not be_valid
  	end
  	
  end
end
