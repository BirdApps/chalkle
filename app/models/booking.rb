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
  scope :status_no, where("bookings.status='no'")

  validates_uniqueness_of :chalkler_id, scope: :lesson_id
  validates_presence_of :lesson_id
  validates_presence_of :chalkler_id

  before_create :set_from_meetup_data
  before_create :set_metadata
  after_create :send_first_email

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
    return cost_override unless cost_override.nil?
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
    if b.lesson.class_not_done
      b.guests = result.guests
      b.status = result.response
    end
    b.meetup_data = result.to_json
    b.save
  end

  def is_teacher
    self.lesson.teacher_id.present? ? (self.chalkler_id == self.lesson.teacher_id) : true
  end

  def emailable
    self.status=='yes' && self.cost > 0 && !self.is_teacher && !self.paid
  end

  def first_email_condition
    self.emailable && self.lesson.class_not_done && !self.lesson.class_coming_up 
  end

  def second_email_condition
    self.emailable && self.lesson.class_coming_up
  end

  def reminder_after_class_condition
    self.emailable && !self.lesson.class_not_done
  end

  def send_first_email
    if first_reminder_condition
      BookingMailer.first_reminder_to_pay(self.chalkler, self.lesson).deliver
    end
  end

  def send_second_email
    if second_reminder_condition
      BookingMailer.second_reminder_to_pay(self.chalkler, self.lesson).deliver
    end
  end

  def send_reminder_after_class
    if reminder_after_class_condition
      BookingMailer.reminder_after_class(self.chalkler, self.lesson).deliver
    end
  end

end
