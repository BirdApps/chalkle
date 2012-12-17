require 'spec_helper'

describe Chalkler do

  it { should have_many(:groups).through(:group_chalklers) }
  it { should validate_uniqueness_of :meetup_id }
  it { should validate_uniqueness_of :email }

  describe ".create_from_meetup_hash" do
    let(:result) { MeetupApiStub.chalkler_response }
    let(:group) { FactoryGirl.create(:group) }

    it "saves valid chalkler" do
      Chalkler.create_from_meetup_hash(result, group)
      Chalkler.find_by_meetup_id(12345678).should be_valid
    end

    it "updates an existing chalkler" do
      @chalkler = FactoryGirl.create(:chalkler, meetup_id: 12345678, name: "Jim Smith")
      Chalkler.create_from_meetup_hash(result, group)
      @chalkler.reload.name.should == "Caitlin Oscars"
    end

    it "saves valid #meetup_data" do
      Chalkler.create_from_meetup_hash(result, group)
      @chalkler = Chalkler.find_by_meetup_id 12345678
      @chalkler.meetup_data["id"].should == 12345678
      @chalkler.meetup_data["name"].should == "Caitlin Oscars"
    end
  end

  describe "#set_from_meetup_data" do
    let(:result) { MeetupApiStub::chalkler_response }
    let(:group) { FactoryGirl.create(:group) }

    it "saves correct created_at value" do
      Chalkler.create_from_meetup_hash(result, group)
      @chalkler = Chalkler.find_by_meetup_id 12345678
      @chalkler.created_at.to_time.to_i.should == 1346658337
    end
  end
end
