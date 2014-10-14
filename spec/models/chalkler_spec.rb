require 'spec_helper'
require "pundit/rspec"

describe Chalkler do
  let(:channel) { FactoryGirl.create(:channel) }

  specify { expect( FactoryGirl.build(:chalkler) ).to be_valid }
  specify { expect( FactoryGirl.build(:meetup_chalkler) ).to be_valid }

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

      expect(subject.is_following?(channel)).to be true
    end

    it "is false if has subscription to channel" do
      expect(subject.is_following?(channel)).to be_falsey
    end
  end

  describe "emails" do
    describe '.email_frequency_select_options' do
      it "provides an array of options that can be used in select dropdowns" do
        stub_const("Chalkler::EMAIL_FREQUENCY_OPTIONS", %w(yes no))

        required_array = [%w(Yes yes), %w(No no)]
        expect(Chalkler.email_frequency_select_options).to eq(required_array)
      end
    end

    it "defaults to receiving weekly emails for all categories" do
      expect(Chalkler.new.email_frequency).to eq 'weekly'
    end
  end

  describe '.teachers' do
    it "includes chalklers who are teachers" do
      chalkler = FactoryGirl.create(:chalkler)
      course = FactoryGirl.create(:course, name: "New Class", teacher_id: chalkler.id)
      expect(Chalkler.teachers).to include(chalkler)
    end

    it "excludes chalklers who are not teachers" do
      chalkler = FactoryGirl.create(:chalkler)
      expect(Chalkler.teachers).not_to include(chalkler)
    end
  end

end
