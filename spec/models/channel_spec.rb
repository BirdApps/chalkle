require 'spec_helper'

describe Channel do
  specify { FactoryGirl.build(:channel).should be_valid }

  it { should validate_presence_of :name }
  it { should validate_presence_of :teacher_percentage }
  it { should validate_presence_of :channel_percentage }

  let(:channel) { FactoryGirl.create(:channel) }

  describe "default values" do

  	it "should set default teacher percentage" do
  		channel.teacher_percentage.should == 0.75
  	end

  	it "should set default channel percentage" do
  		channel.channel_percentage.should == 0.125
  	end

  	it "should set default chalkle percentage" do
  		channel.chalkle_percentage.should == 0.125
  	end

    it "hides channel by default" do
      channel.visible.should be_false
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

  	it "should not allow sum of percentages greater than 0.875" do
  		channel.channel_percentage = 0.6
  		channel.teacher_percentage = 0.4
  		channel.should_not be_valid
  	end

    it "should not allow bank account number not in the correct format" do
      channel.account = '12312-12'
      channel.should_not be_valid
    end

    it "should not allow bank account number containing letters" do
      channel.account = '12-1231-43243Arewr-34'
      channel.should_not be_valid
    end

    describe "email" do
      it "should not allow email without @" do
        FactoryGirl.build(:channel, email: "abs123").should_not be_valid
      end

      it "should not allow with @ but no ." do
        FactoryGirl.build(:channel, email: "abs123").should_not be_valid
      end
    end
  end

  describe "scopes" do
    describe ".visible" do
      it "returns visible records" do
        FactoryGirl.create(:channel, visible: true)
        Channel.visible.exists?.should be_true
      end

      it "ignores invisible records" do
        FactoryGirl.create(:channel)
        Channel.visible.exists?.should be_false
      end
    end

    describe ".hidden" do
      it "returns invisible records" do
        FactoryGirl.create(:channel)
        Channel.hidden.exists?.should be_true
      end

      it "ignores visible records" do
        FactoryGirl.create(:channel, visible: true)
        Channel.hidden.exists?.should be_false
      end
    end
  end

  describe ".select_options" do
  	let(:chalkler) { FactoryGirl.create(:chalkler)}
    let(:channel1) { FactoryGirl.create(:channel, name: "channel1") }
  	let(:channel2) { FactoryGirl.create(:channel, name: "channel2") }

    before do
      chalkler.channels << channel1
      chalkler.channels << channel2
    end

  	it "should provide an array of options that can be used in dropdowns" do
  		required_array = [['channel1', channel1.id],['channel2', channel2.id]]
  		Channel.select_options(chalkler.channels).should eq(required_array)
  	end
  end

end
