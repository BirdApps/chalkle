class Chalkler < ActiveRecord::Base
  attr_accessible :bio, :email, :meetup_data, :meetup_id, :name
  validates_uniqueness_of :meetup_id, allow_blank: true
  validates_uniqueness_of :email, allow_blank: true

  has_many :bookings
  has_many :lessons, through: :bookings
  has_many :lessons_taught, class_name: "Lesson", foreign_key: "teacher_id"
  has_many :payments

  before_create :set_from_meetup_data

  def meetup_data
    data = read_attribute(:meetup_data)
    if data.present?
      JSON.parse(data)
    else
      {}
    end
  end

  def set_from_meetup_data
    return if meetup_data.empty?
    self.created_at = Time.at(meetup_data["joined"] / 1000)
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
