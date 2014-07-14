module MeetupApiStub

  def self.chalkler_response
    RMeetup::Type::Member.new({
      "id" => 12345678,
      "joined" => 1346658337000,
      "bio" => "Web dev who loves coffee yoga and every new moment",
      "name" => "Caitlin Oscars",
      "email" => "caitlin@gmail.com"
    })
  end

  def self.course_response
    RMeetup::Type::Event.new({
      "status" => "upcoming",
      "id" => 12345678,
      "name" => "music and dance: awesome class",
      "description" => "all about the class",
      "created" => 1351297791000,
      "updated" => 1351297791000,
      "time" => 1351297791000,
      "duration" => 600000,
      "rsvp_limit" => 10
    })
  end

  def self.rsvp_response
    RMeetup::Type::Rsvp.new({
      "rsvp_id" => 12345678,
      "member" => { "member_id" => 12345678 },
      "event" => { "id" => 12345678 },
      "guests" => 1,
      "response" => "yes",
      "created" => 1351297791000,
      "mtime" => 1351297791000
    })
  end

  def self.venue_response
    RMeetup::Type::Venue.new({
      "id" => 123456578,
      "name" => "Venue",
      "address_1" => "100 Example Lane",
      "address_2" => "Newtown",
      "city" => "Wellington",
      "lon" => 174.77327,
      "lat" => -41.333698,
    })
  end

end