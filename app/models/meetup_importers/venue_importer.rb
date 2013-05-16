class VenueImporter

  attr_accessor :results

  def initialize(channel)
    @channel = channel
    @results = []
  end

  def self.import(channel)
    v = VenueImporter.new channel
    v.fetch_venues
    v.update_records
  end

  def fetch_venues
    self.results = RMeetup::Client.fetch(:venues, { group_urlname: @channel.url_name })
  end

  def update_records
    results.each do |result|
      v = Venue.find_or_initialize_by_meetup_id result.id
      v.meetup_id = result.id
      v.name = result.name
      v.address_1 = result.address_1
      v.lon = result.lon
      v.lat = result.lat
      v.city = City.where{ name == result.city.capitalize }.first_or_create
      v.save
    end
  end

end
