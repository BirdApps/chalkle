class Booking < ActiveRecord::Base
  attr_accessible :chalkler_id, :lesson_id, :meetup_data, :status, :guests, :meetup_id, :cost_override, :paid, :visible

  belongs_to :lesson
  belongs_to :chalkler
  has_one :payment

  scope :paid, where(paid: true)
  scope :unpaid, where("bookings.paid IS NOT true")
  scope :confirmed, where(status: "yes")
  scope :waitlist, where(status: "waitlist")
  scope :interested, where("bookings.status='yes' OR bookings.status='waitlist' OR bookings.status='no-show'")
  scope :billable, joins(:lesson).where("(lessons.cost > 0 AND bookings.status='yes') AND ((bookings.chalkler_id != lessons.teacher_id) OR (bookings.guests>0))")
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)

  validates_uniqueness_of :chalkler_id, scope: :lesson_id
  validates_presence_of :lesson_id
  validates_presence_of :chalkler_id

  before_create :set_from_meetup_data
  before_create :set_metadata

  def name
    if lesson.present? && chalkler.present?
      "#{lesson.name} (#{lesson.meetup_id}) - #{chalkler.name}"
    else
      id
    end
  end

  def meetup_data
    data = read_attribute(:meetup_data)
    if data.present?
      rsvp = JSON.parse(data)
      rsvp["rsvp"]
    else
      {}
    end
  end

  def cost
    return cost_override if (cost_override? || cost_override===0)
    seats = guests.present? ? guests + 1 : 1
    lesson.cost.present? ? (lesson.cost * seats) : nil
  end

  def answers
    return if meetup_data.empty? || (meetup_data["answers"][0] == "" && meetup_data["answers"].length == 1)
    meetup_data["answers"]
  end

  def set_from_meetup_data
    return if meetup_data.empty?
    self.created_at = Time.at(meetup_data["created"] / 1000)
    self.updated_at = Time.at(meetup_data["mtime"] / 1000)
  end

  def set_metadata
    self.visible = true
  end

  def self.create_from_meetup_hash result
    b = Booking.find_or_initialize_by_meetup_id result.rsvp_id
    b.chalkler = Chalkler.find_by_meetup_id result.member["member_id"]
    b.lesson = Lesson.find_by_meetup_id result.event["id"]
    b.meetup_id = result.rsvp_id
    b.guests = result.guests
    b.status = result.response unless b.status == "no-show"
    b.meetup_data = result.to_json
    b.save
  end
end
