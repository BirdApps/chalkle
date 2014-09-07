class Booking < ActiveRecord::Base
  PAYMENT_METHODS = [Finance::PaymentMethods::Cash.new, Finance::PaymentMethods::Bank.new, Finance::PaymentMethods::CreditCard.new]
  attr_accessible :course_id, :guests, :payment_method, :terms_and_conditions
  attr_accessible :chalkler_id, :chalkler, :course_id, :course, :meetup_data, :status, :guests, :meetup_id, :cost_override, :paid, :payment_method, :visible, :reminder_last_sent_at, :as => :admin

  attr_accessor :terms_and_conditions
  attr_accessor :enforce_terms_and_conditions

  belongs_to :course
  belongs_to :chalkler
  has_one :payment

  validates_presence_of :course_id, :chalkler_id, :status
  validates_presence_of :payment_method, :unless => :free?
  validates_acceptance_of :terms_and_conditions, :message => 'please read and agree', :if => :enforce_terms_and_conditions
  validates_uniqueness_of :chalkler_id, scope: :course_id

  scope :paid, where{ paid == true }
  scope :unpaid, where{ paid == false }
  scope :confirmed, where(status: 'yes')
  scope :waitlist, where(status: 'waitlist')
  scope :status_no, where(status: 'no')
  scope :interested, where{ (status == 'yes') | (status == 'waitlist') | (status == 'no-show') }
  scope :billable, joins(:course).where{ (courses.cost > 0) & (status == 'yes') & ((chalkler_id != courses.teacher_id) | (guests > 0)) }
  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :course_visible, joins(:course).where('courses.visible = ?', true)
  scope :upcoming, course_visible.joins(:course => :lessons).where( 'start_at > ?', Time.now )

  before_validation :set_free_course_attributes

  delegate :name, :start_at, :venue, :prerequisites, :teacher_id, :meetup_url, :cose, to: :course, prefix: true
  delegate :free?, to: :course, allow_nil: true

  BOOKING_STATUSES = %w(yes waitlist no pending no-show)

  def name
    if course.present? && chalkler.present?
      if course.meetup_id.present?
        "#{course.name} (#{course.meetup_id}) - #{chalkler.name}"
      else
        "#{course.name} - #{chalkler.name}"
      end
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
    course.cost.present? ? (course.cost * seats) : nil
  end

  def answers
    return if meetup_data.empty? || (meetup_data["answers"][0] == "" && meetup_data["answers"].length == 1)
    meetup_data["answers"]
  end

  def refundable?
    course_start_at > (Time.now + 3.days)
  end

  def teacher?
    return false unless course_teacher_id
    chalkler_id == course_teacher_id
  end

  def cancelled?
    (status == 'no') ? true : false
  end

  # Refactor all of this:

  def emailable
    status == 'yes' && (cost ? cost : 0) > 0 && !teacher? && (paid != true) && course_teacher_id.present?
  end

  def first_email_condition
    self.emailable && self.course.class_not_done && !self.course.class_coming_up
  end

  def second_email_condition
    self.emailable && self.course.class_coming_up && (self.chalkler.email.nil? || self.chalkler.email == "")
  end

  def third_email_condition
    self.status=='waitlist' && (self.cost.present? ? self.cost : 0) > 0 && !self.teacher? && (self.paid!=true) && self.course.class_coming_up
  end

  def reminder_after_class_condition
    self.emailable && !self.course.class_not_done
  end

  def no_show_email_condition
    self.status=='no-show' && !self.teacher? && (self.paid!=true) && !self.course.class_not_done
  end

  def reminder_email_choice
    if first_email_condition
      return 1
    elsif second_email_condition
      return 2
    elsif third_email_condition
      return 3
    elsif reminder_after_class_condition
      return 4
    elsif no_show_email_condition
      return "no-show"
    else
      return false
    end
  end

  private

  def set_free_course_attributes
    if course && free?
      self.payment_method = 'free'
      self.paid = true
    end
  end
end
