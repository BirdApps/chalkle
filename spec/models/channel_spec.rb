require 'spec_helper'

describe Channel do
  specify { expect(FactoryGirl.build(:channel)).to be_valid }

  it { should validate_presence_of :name }
  it { should validate_presence_of :teacher_percentage }

  let(:channel) { FactoryGirl.create(:channel) }

  describe "default values" do
    it "hides channel by default" do
      expect(channel.visible).to be_falsey
    end
  end

  describe "validation" do
  	it "should not allow teacher percentage greater than 1" do
  		channel.teacher_percentage = 1.2
  		expect(channel).not_to be_valid
  	end

    pending "should not allow bank account number not in the correct format" do
      channel.account = '12312-12'
      expect(channel).not_to be_valid
    end

    pending "should not allow bank account number containing letters" do
      channel.account = '12-1231-43243Arewr-34'
      expect(channel).not_to be_valid
    end

    describe "email" do
      it "should not allow email without @" do
        expect(FactoryGirl.build(:channel, email: "abs123")).not_to be_valid
      end

      it "should not allow with @ but no ." do
        expect(FactoryGirl.build(:channel, email: "abs123")).not_to be_valid
      end
    end
  end

  describe "scopes" do
    describe ".visible" do
      it "returns visible records" do
        FactoryGirl.create(:channel, visible: true)
        expect(Channel.visible.exists?).to be true
      end

      it "ignores invisible records" do
        FactoryGirl.create(:channel)
        expect(Channel.visible.exists?).to be false
      end
    end

    describe ".hidden" do
      it "returns invisible records" do
        FactoryGirl.create(:channel)
        expect(Channel.hidden.exists?).to be true
      end

      it "ignores visible records" do
        FactoryGirl.create(:channel, visible: true)
        expect(Channel.hidden.exists?).to be false
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
  		expect(Channel.select_options(chalkler.channels)).to eq(required_array)
  	end
  end


end
