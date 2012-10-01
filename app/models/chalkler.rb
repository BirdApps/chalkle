class Chalkler < ActiveRecord::Base
  attr_accessible :bio, :email, :meetup_data, :meetup_id, :name
  validates_uniqueness_of :meetup_id
  validates_uniqueness_of :email, allow_nil: true

  has_many :bookings
  has_many :lessons, through: :bookings

  def meetup_data
    JSON.parse(read_attribute(:meetup_data))
  end

  def self.create_from_meetup_hash result
    require 'iconv'
    conv = Iconv.new('UTF-8','LATIN1')

    c = Chalkler.new
    c.name = conv.iconv(result["name"])
    c.meetup_id = result["id"]
    c.bio = conv.iconv(result["bio"])
    c.meetup_data = conv.iconv(result.to_json)
    c.save
  end

end
