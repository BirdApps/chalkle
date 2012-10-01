class Booking < ActiveRecord::Base
  attr_accessible :chalkler_id, :lesson_id, :meetup_data, :status, :guests, :meetup_id, :paid

  belongs_to :lesson
  belongs_to :chalkler

  scope :paid, where(paid: true)
  scope :confirmed, where(status: "yes")

  def meetup_data
    JSON.parse(read_attribute(:meetup_data))
  end

  def self.create_from_meetup_hash result
    require 'iconv'
    conv = Iconv.new('UTF-8','LATIN1')
    b = Booking.new
    b.chalkler = Chalkler.find_by_meetup_id result["member_id"]
    b.lesson = Lesson.find_by_meetup_id result["event_id"]
    b.meetup_id = result["rsvp_id"]
    b.guests = result["guests"]
    b.status = result["response"]
    b.meetup_data = conv.iconv(result.to_json)
    b.save
  end
end
