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

  class BookingResponse
    attr_reader :rsvp_id, :member, :event, :guests, :response
    def initialize
      @rsvp_id = 12345678
      @member = { "member_id" => 12345678 }
      @event = { "id" => 12345678 }
      @guests = 1
      @response = "yes"
    end
  end
end