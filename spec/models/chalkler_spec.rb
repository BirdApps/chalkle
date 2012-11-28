require 'spec_helper'

describe Chalkler do

  it { should have_many(:groups).through(:group_chalklers) }
  it { should validate_uniqueness_of :meetup_id }
  it { should validate_uniqueness_of :email }

  describe "user import" do
    result = MeetupApiStub.chalkler_response

    it "creates a new user using meetup data" do
      Chalkler.create_from_meetup_hash(result, FactoryGirl.create(:group)).should be_true
    end

    it "will update an existing user using meetup data" do
      Chalkler.create_from_meetup_hash(result, FactoryGirl.create(:group))
      c = Chalkler.find_by_name "Caitlin Oscars"
      c.name = "John"
      c.save
      Chalkler.create_from_meetup_hash(result, FactoryGirl.create(:group))
      c.reload.name.should == "Caitlin Oscars"
    end
  end
end
