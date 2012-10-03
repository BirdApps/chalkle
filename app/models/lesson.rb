class Lesson < ActiveRecord::Base
  attr_accessible :name, :meetup_id, :category_id, :teacher_id, :title, :status, :cost, :start_at, :duration, :meetup_data, :description

  belongs_to :category
  belongs_to :teacher

  has_many :bookings
  has_many :chalklers, through: :bookings

  validates_uniqueness_of :meetup_id, allow_nil: true

  before_create :set_from_meetup_data

  def meetup_data
    JSON.parse(read_attribute(:meetup_data))
  end

  def set_from_meetup_data
    self.created_at = Time.at(meetup_data["created"] / 1000)
    self.updated_at = Time.at(meetup_data["updated"] / 1000)
    self.start_at = Time.at(meetup_data["time"] / 1000) if meetup_data["time"]
    self.duration = meetup_data["duration"] / 1000 if meetup_data["duration"]
    parts = name.split(":")
    c = Category.find_by_name parts[0]
    if c.present?
      self.category = c
      self.name = parts[1]
    end
  end

  def self.create_from_meetup_hash result
    require 'iconv'
    conv = Iconv.new('UTF-8','LATIN1')

    l = Lesson.new
    l.name = conv.iconv(result["name"])
    l.meetup_id = result["id"]
    l.meetup_data = conv.iconv(result.to_json)
    l.description = conv.iconv(result["description"])
    l.save
  end
end
