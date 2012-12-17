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

  def self.lesson_response
    RMeetup::Type::Event.new({
      "id" => 12345678,
      "name" => "awesome class",
      "description" => "all about the class",
      "created" => 1351297791000,
      "updated" => 1351297791000,
      "time" => 1351297791000,
      "duration" => 6000
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
end