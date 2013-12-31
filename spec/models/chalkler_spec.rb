require 'spec_helper'

describe Chalkler do
  let(:channel) { FactoryGirl.create(:channel) }

  specify { FactoryGirl.build(:chalkler).should be_valid }
  specify { FactoryGirl.build(:meetup_chalkler).should be_valid }
  

  describe "validation" do
    subject { Chalkler.new }

    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :email }

    context "non-meetup" do
      before { subject.stub(:meetup_id) { nil } }
      it { should validate_presence_of :email }
    end
  end

  describe "is_following" do
    subject { FactoryGirl.create(:chalkler) }
    it "is true if has subscription to channel" do
      subject.channels << channel

      subject.is_following?(channel).should be_true
    end

    it "is false if has subscription to channel" do
      subject.is_following?(channel).should be_false
    end
  end

  describe '.email_frequency_select_options' do
    it "provides an array of options that can be used in select dropdowns" do
      stub_const("Chalkler::EMAIL_FREQUENCY_OPTIONS", %w(yes no))

      required_array = [%w(Yes yes), %w(No no)]
      Chalkler.email_frequency_select_options.should eq(required_array)
    end
  end

  describe '.teachers' do
    it "includes chalklers who are teachers" do
      chalkler = FactoryGirl.create(:chalkler)
      lesson = FactoryGirl.create(:lesson, name: "New Class", teacher_id: chalkler.id)
      Chalkler.teachers.should include(chalkler)
    end

    it "excludes chalklers who are not teachers" do
      chalkler = FactoryGirl.create(:chalkler)
      Chalkler.teachers.should_not include(chalkler)
    end
  end

end
