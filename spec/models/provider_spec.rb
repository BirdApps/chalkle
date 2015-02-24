require 'spec_helper'

describe Provider do
  specify { expect(FactoryGirl.build(:provider)).to be_valid }

  it { should validate_presence_of :name }
  it { should validate_presence_of :teacher_percentage }

  let(:provider) { FactoryGirl.create(:provider) }

  describe "default values" do
    it "hides provider by default" do
      expect(provider.visible).to be_falsey
    end
  end

  describe "validation" do
  	it "should not allow teacher percentage greater than 1" do
  		provider.teacher_percentage = 1.2
  		expect(provider).not_to be_valid
  	end

    pending "should not allow bank account number not in the correct format" do
      provider.account = '12312-12'
      expect(provider).not_to be_valid
    end

    pending "should not allow bank account number containing letters" do
      provider.account = '12-1231-43243Arewr-34'
      expect(provider).not_to be_valid
    end

    describe "email" do
      it "should not allow email without @" do
        expect(FactoryGirl.build(:provider, email: "abs123")).not_to be_valid
      end

      it "should not allow with @ but no ." do
        expect(FactoryGirl.build(:provider, email: "abs123")).not_to be_valid
      end
    end
  end

  describe "scopes" do
    describe ".visible" do
      it "returns visible records" do
        FactoryGirl.create(:provider, visible: true)
        expect(Provider.visible.exists?).to be true
      end

      it "ignores invisible records" do
        FactoryGirl.create(:provider)
        expect(Provider.visible.exists?).to be false
      end
    end

    describe ".hidden" do
      it "returns invisible records" do
        FactoryGirl.create(:provider)
        expect(Provider.hidden.exists?).to be true
      end

      it "ignores visible records" do
        FactoryGirl.create(:provider, visible: true)
        expect(Provider.hidden.exists?).to be false
      end
    end
  end

  describe ".select_options" do
  	let(:chalkler) { FactoryGirl.create(:chalkler)}
    let(:provider1) { FactoryGirl.create(:provider, name: "provider1") }
  	let(:provider2) { FactoryGirl.create(:provider, name: "provider2") }

    before do
      chalkler.providers << provider1
      chalkler.providers << provider2
    end

  	it "should provide an array of options that can be used in dropdowns" do
  		required_array = [['provider1', provider1.id],['provider2', provider2.id]]
  		expect(Provider.select_options(chalkler.providers)).to eq(required_array)
  	end
  end


end
