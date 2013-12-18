require 'spec_helper'
require 'chalkle_meetup/chalkler_importer'

describe ChalkleMeetup::ChalklerImporter do
  context "imported from Meetup" do
    let(:result) { MeetupApiStub::chalkler_response }
    let(:channel) { FactoryGirl.create(:channel) }

    describe "#import" do
      context "creating new chalkler" do
        before do
          @chalkler = subject.import(result, channel)
        end

        pending "saves valid chalkler" do
          @chalkler.reload.should be_valid
        end

        it "saves valid #meetup_data" do
          @chalkler.meetup_data["id"].should == 12345678
          @chalkler.meetup_data["name"].should == "Caitlin Oscars"
        end

        it "saves correct created_at value" do
          @chalkler.created_at.to_time.to_i.should == 1346658337
        end
      end

      context "updating existing chalkler" do
        it "updates an existing chalkler" do
          chalkler = FactoryGirl.create(:chalkler, uid: result.id.to_s, provider: 'meetup', name: "Jim Smith")
          @chalkler = subject.import(result, channel)

          @chalkler.id.should == chalkler.id
          @chalkler.reload.bio.should_not be_nil
        end
      end
    end
  end
end