require 'spec_helper'

describe Channel do
  specify { FactoryGirl.build(:channel).should be_valid }

  it { should validate_presence_of :name }
  it { should validate_presence_of :teacher_percentage }

  let(:channel) { FactoryGirl.create(:channel) }

  describe "default values" do
    it "hides channel by default" do
      channel.visible.should be_false
    end
  end

  describe "validation" do
  	it "should not allow teacher percentage greater than 1" do
  		channel.teacher_percentage = 1.2
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

  describe ".cost_calculator_class" do
    before do
      CostModel.create!(calculator_class_name: 'flat_rate_markup')
    end

    it "returns the default cost calculator if no model is specified" do
      subject.cost_model = nil
      subject.cost_calculator.should be_a(Finance::ClassCostCalculators::FlatRateMarkup)
    end

    it "returns the cost calculator for this channel's cost model" do
      subject.cost_model = CostModel.create!(calculator_class_name: 'percentage_commission')
      subject.cost_calculator.should be_a(Finance::ClassCostCalculators::PercentageCommission)
    end
  end

end
