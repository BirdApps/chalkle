require 'spec_helper'
require "pundit/rspec"

describe Chalkler do
  let(:provider) { FactoryGirl.create(:provider) }

  specify { expect( FactoryGirl.build(:chalkler) ).to be_valid }

  describe "validation" do
    subject { FactoryGirl.build(:chalkler) }

    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :email }

  end

  describe "sets a notification preference for new chalklers" do
    let(:chalkler) { FactoryGirl.create(:chalkler) }

    it 'should add notification preference to new chalklers' do 
      expect( chalkler.notification_preference ).not_to be_nil 
    end
  end

  describe "#send_welcome_mail" do
    let(:chalkler) { FactoryGirl.build(:chalkler) }
    it 'should send welcome mailer on chalkler create' do
      expect{ chalkler.save }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end


  describe "is_following" do
    subject { FactoryGirl.create(:chalkler) }
    it "is true if has subscription to provider" do
      subject.providers << provider

      expect(subject.is_following?(provider)).to be true
    end

    it "is false if has subscription to provider" do
      expect(subject.is_following?(provider)).to be_falsey
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

    it "defaults to receiving weekly emails" do
      expect(Chalkler.new.email_frequency).to eq 'weekly'
    end
  end

end
