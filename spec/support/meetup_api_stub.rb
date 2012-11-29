module MeetupApiStub
  def self.chalkler_response
    {
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
  end

  def self.booking_response
    {
      "zip"=>"meetup5",
      "lon"=>"174.77999877929688",
      "photo_url"=>"http://photos1.meetupstatic.com/photos/member/2/9/member_12345678.jpeg",
      "link"=>"http://www.meetup.com/members/12345678",
      "state"=>"",
      "answers"=>["It's ALL gonna be awesome!"],
      "guests"=>"1",
      "event_id"=>12345678,
      "member_id"=>12345678,
      "city"=>"Wellington",
      "country"=>"nz",
      "response"=>"yes",
      "coord"=>"-41.279998779296875",
      "id"=>"12345678",
      "updated"=>"Sun Oct 14 20:27:53 EDT 2012",
      "created"=>"Sun Oct 14 20:26:27 EDT 2012",
      "name"=>"jane whitcroft",
      "comment"=>""
    }
  end
end