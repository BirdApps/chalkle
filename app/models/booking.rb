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
  validates_presence_of :lesson_id
  validates_presence_of :chalkler_id

  before_create :set_from_meetup_data

  def meetup_data
    data = read_attribute(:meetup_data)
    if data.present?
      JSON.parse(data)
    else
      {}
    end
  end

  def cost
    lesson.cost * (1 + guests) if lesson.cost.present?
  end

  def self.nonzero
    joins(:lesson).where("lessons.cost > 0")
  end

  def set_from_meetup_data
    return if meetup_data.empty?
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
    b = Booking.find_by_meetup_id(result["id"]) || Booking.new
    b.chalkler = Chalkler.find_by_meetup_id result["member_id"]
    b.lesson = Lesson.find_by_meetup_id result["event_id"]
    b.meetup_id = result["id"]
    b.guests = result["guests"]
    b.status = result["response"]
    b.meetup_data = conv.iconv(result.to_json)
    b.save
  end
end
