class Lesson < ActiveRecord::Base
  attr_accessible :name, :meetup_id, :category_id, :teacher_id, :kind, :title, :doing, :learn, :skill, :skill_note, :bring, :charge, :cost, :note, :start, :end, :link, :meetup_data

  belongs_to :category
  belongs_to :teacher

  has_many :bookings
  has_many :chalklers, through: :bookings

  validates_uniqueness_of :meetup_id, allow_nil: true

  def meetup_data
    JSON.parse(read_attribute(:meetup_data))
  end

  def self.create_from_meetup_hash result
    require 'iconv'
    conv = Iconv.new('UTF-8','LATIN1')

    l = Lesson.new
    l.name = conv.iconv(result["name"])
    l.meetup_id = result["id"]
    l.meetup_data = conv.iconv(result.to_json)
    l.save
  end
end
