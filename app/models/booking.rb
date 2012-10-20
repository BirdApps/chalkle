class Booking < ActiveRecord::Base
  attr_accessible :chalkler_id, :lesson_id, :meetup_data, :status, :guests, :meetup_id, :paid

  belongs_to :lesson
  belongs_to :chalkler

  has_one :payment

  scope :paid, where(paid: true)
  scope :unpaid, where("paid IS NOT true")
  scope :confirmed, where(status: "yes")

  validates_uniqueness_of :chalkler_id, scope: :lesson_id
  validates_uniqueness_of :meetup_id, allow_nil: true

  before_create :set_from_meetup_data

  def meetup_data
    JSON.parse(read_attribute(:meetup_data)) if read_attribute(:meetup_data).present?
  end

  def set_from_meetup_data
    self.created_at = meetup_data["created"]
    self.updated_at = meetup_data["updated"]
  end

  def name
    if lesson.present? && chalkler.present?
      "#{lesson.name} (#{lesson.meetup_id}) - #{chalkler.name}"
    else
      id
    end
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
