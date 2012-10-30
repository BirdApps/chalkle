require 'spec_helper'

describe Chalkler do

  it { should validate_uniqueness_of :meetup_id }
  it { should validate_uniqueness_of :email }

  describe "user import" do

    # ugly I know
    result = {
      "lon"=>174.77999877929688,
      "link"=>"http://www.meetup.com/members/12345678",
      "self"=>{"common"=>{}},
      "lang"=>"en_US",
      "photo"=>{
        "photo_link"=>"http://photos4.meetupstatic.com/photos/member/a/7/a/0/member_12345678.jpeg",
        "thumb_link"=>"http://photos4.meetupstatic.com/photos/member/a/7/a/0/thumb_12345678.jpeg",
        "photo_id"=>12345678
      },
      "city"=>"Wellington",
      "country"=>"nz",
      "id"=>12345678,
      "visited"=>1349206517000,
      "topics"=>[
        {"id"=>638, "urlkey"=>"hiking", "name"=>"Hiking"},
        {"id"=>7203, "urlkey"=>"edtech", "name"=>"Education & Technology"},
        {"id"=>19491, "urlkey"=>"outdoor-activities", "name"=>"Outdoor activities"}
      ],
      "joined"=>1346658337000,
      "bio"=>"Web dev who loves coffee yoga and every new moment",
      "name"=>"Caitlin Oscars",
      "other_services"=>{},
      "lat"=>-41.279998779296875
    }

    pending "converts LATIN1 strings to UTF8" do
    end

    it "creates a new user using meetup data" do
      Chalkler.create_from_meetup_hash(result).should be_true
    end

    it "will update an existing user using meetup data" do
      c = FactoryGirl.create(:chalkler, name: "Jimmy Jones")
      Chalkler.create_from_meetup_hash(result)
      c.reload.name.should == "Caitlin Oscars"
    end
  end
end
