require 'spec_helper'

describe Chalkler do

  it { should have_many(:channels).through(:channel_chalklers) }

  describe '.email_frequency_select_options' do
    it "provides an array of options that can be used in select dropdowns" do
      stub_const("Chalkler::EMAIL_FREQUENCY_OPTIONS", %w(yes no))

      required_array = [%w(Yes yes), %w(No no)]
      Chalkler.email_frequency_select_options.should eq(required_array)
    end
  end

  describe "record creation" do
    specify { FactoryGirl.build(:chalkler).should be_valid }
    specify { FactoryGirl.build(:meetup_chalkler).should be_valid }

    it { should validate_uniqueness_of :meetup_id }
    it { should validate_uniqueness_of :email }

    it "should validate GST numbers" do
      FactoryGirl.build(:chalkler, gst: "ash 8765").should_not be_valid
      FactoryGirl.build(:chalkler, gst: "23-345 8765").should be_valid
    end

    context "created from meetup user" do
      let(:result) { MeetupApiStub::chalkler_response }
      let(:channel) { FactoryGirl.create(:channel) }

      describe "#set_from_meetup_data" do
        it "saves correct created_at value" do
          Chalkler.create_from_meetup_hash(result, channel)
          chalkler = Chalkler.find_by_meetup_id 12345678
          chalkler.created_at.to_time.to_i.should == 1346658337
        end
      end

      describe ".create_from_meetup_hash" do
        it "saves valid chalkler" do
          Chalkler.create_from_meetup_hash(result, channel)
          Chalkler.find_by_meetup_id(12345678).should be_valid
        end

        it "updates an existing chalkler" do
          chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678, name: "Jim Smith")
          Chalkler.create_from_meetup_hash(result, channel)
          chalkler.reload.name.should == "Caitlin Oscars"
        end

        it "saves valid #meetup_data" do
          Chalkler.create_from_meetup_hash(result, channel)
          chalkler = Chalkler.find_by_meetup_id 12345678
          chalkler.meetup_data["id"].should == 12345678
          chalkler.meetup_data["name"].should == "Caitlin Oscars"
        end
      end

    end

    context "created by admin" do
      let(:chalkler) { FactoryGirl.create(:chalkler, meetup_id: nil) }
      let(:meetup_chalkler) { FactoryGirl.create(:meetup_chalkler) }

      describe "#set_reset_password_token" do
        it "should create reset_password_token" do
          chalkler.reset_password_token.should be_present
        end

        it "won't set a token for a meetup user" do
          meetup_chalkler.reset_password_token.should be_nil
        end
      end

      describe "#send_teacher_welcome_email" do
        before do
          ActionMailer::Base.deliveries = []
        end

        it "should create reset_password_sent_at" do
          chalkler.reset_password_sent_at.should be_present
        end

        it "should send a mail to the new user" do
          chalkler
          ActionMailer::Base.deliveries.length.should == 1
        end

        it "won't email a meetup user" do
          meetup_chalkler
          ActionMailer::Base.deliveries.should be_empty
        end

        it "won't email a user with no email" do
          FactoryGirl.create(:chalkler, email: nil)
          ActionMailer::Base.deliveries.should be_empty
        end
      end

    end
  end

end
