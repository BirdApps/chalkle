require 'spec_helper'

describe Chalkler do

  specify { FactoryGirl.build(:chalkler).should be_valid }
  specify { FactoryGirl.build(:meetup_chalkler).should be_valid }

  describe "validation" do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :meetup_id }
    it { should validate_uniqueness_of :email }

    it "should validate GST numbers" do
      FactoryGirl.build(:chalkler, gst: "ash 8765").should_not be_valid
      FactoryGirl.build(:chalkler, gst: "23-345 8765").should be_valid
    end

    it "validates join_channels on create" do
      FactoryGirl.build(:chalkler, join_channels: nil).should_not be_valid
    end

    it "validates channel_ids on update" do
      chalkler = FactoryGirl.create(:chalkler)
      chalkler.channel_ids = []
      chalkler.should_not be_valid
    end
  end

  describe "record creation" do
    context "imported from Meetup" do
      let(:result) { MeetupApiStub::chalkler_response }
      let(:channel) { FactoryGirl.create(:channel) }

      describe ".import_from_meetup" do
        it "assigns a channel to a new user" do
          chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678)
          Chalkler.import_from_meetup(result, channel)
          chalkler.reload.channels.should include(channel)
        end
      end

      describe ".fetch_chalkler" do
        it "will search Horowhenua chalklers by name" do
          horowhenua = FactoryGirl.create(:channel, url_name: 'horowhenua')
          chalkler = FactoryGirl.create(:chalkler, name: result.name)
          chalkler.channels << horowhenua
          Chalkler.fetch_chalkler(result, horowhenua).should == chalkler
        end
      end

      describe "#create_from_meetup" do
        let(:chalkler) { Chalkler.new }

        before do
          chalkler.create_from_meetup(result, channel)
        end

        it "saves valid chalkler" do
          chalkler.reload.should be_valid
        end

        it "saves valid #meetup_data" do
          chalkler.meetup_data["id"].should == 12345678
          chalkler.meetup_data["name"].should == "Caitlin Oscars"
        end

        it "saves correct created_at value" do
          chalkler.created_at.to_time.to_i.should == 1346658337
        end
      end

      describe "#update_from_meetup" do
        it "updates an existing chalkler" do
          chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678, name: "Jim Smith")
          chalkler.update_from_meetup(result)
          chalkler.reload.bio.should_not be_nil
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

  describe '.email_frequency_select_options' do
    it "provides an array of options that can be used in select dropdowns" do
      stub_const("Chalkler::EMAIL_FREQUENCY_OPTIONS", %w(yes no))

      required_array = [%w(Yes yes), %w(No no)]
      Chalkler.email_frequency_select_options.should eq(required_array)
    end
  end

end
