class Booking < ActiveRecord::Base
  attr_accessible :chalkler_id, :lesson_id, :meetup_data, :status, :guests, :meetup_id, :paid

  belongs_to :lesson
  belongs_to :chalkler
  has_one :payment

  scope :paid, where(paid: true)
  scope :unpaid, where("bookings.paid IS NOT true")
  scope :confirmed, where(status: "yes")
  scope :waitlist, where(status: "waitlist")
  scope :interested, where("bookings.status='yes' OR bookings.status='waitlist' OR bookings.status='no-show' ")
  scope :billable, joins(:lesson).where("lessons.cost > 0 and bookings.status='yes' ")

  validates_uniqueness_of :chalkler_id, scope: :lesson_id
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
    if lesson.cost.present? && guests.present?
      lesson.cost*(1 + guests) if lesson.cost.present?
    end
    if lesson.cost.present?
      lesson.cost*(1 + 0)
    end
  end

  def set_paid
    #set paid to true for free classes
    if self.lesson.cost.present? && self.lesson.cost==0.0
      self.paid = true
      self.save
    end
    #set paid to true for teachers
    if self.lesson.teacher_id.present? && self.chalkler_id==self.lesson.teacher_id
      self.paid = true
      self.save
   end
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
    b = Booking.find_or_initialize_by_meetup_id result.rsvp_id
    b.chalkler = Chalkler.find_by_meetup_id result.member["member_id"]
    b.lesson = Lesson.find_by_meetup_id result.event["id"]
    b.meetup_id = result.rsvp_id
    b.guests = result.guests 
    b.status = result.response
    b.meetup_data = result.to_json
    b.save
  end
end
