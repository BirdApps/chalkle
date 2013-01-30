class Lesson < ActiveRecord::Base
  attr_accessible :name, :meetup_id, :category_id, :teacher_id, :title, :status, :cost, :teacher_cost, :venue_cost, :start_at, :duration, :meetup_data, :description, :visible, :teacher_payment

  has_many :group_lessons
  has_many :groups, :through => :group_lessons
  belongs_to :category
  belongs_to :teacher, class_name: "Chalkler"

  has_many :bookings
  has_many :chalklers, :through => :bookings
  has_many :payments, :through => :bookings

  validates_uniqueness_of :meetup_id, allow_nil: true
  validates_numericality_of :teacher_payment, allow_nil: true

  #Time span for classes requiring attention
  PAST = 3
  IMMEDIATE_FUTURE= 5
  WEEK = 7

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :recent, where("start_at > current_date - " + PAST.to_s + " AND start_at < current_date + " + IMMEDIATE_FUTURE.to_s)
  scope :upcoming, where("start_at >= current_date AND start_at < current_date + " + WEEK.to_s)
  scope :last_week, where("start_at > current_date - " + WEEK.to_s + " AND start_at < current_date ")

  before_create :set_from_meetup_data
  before_create :set_metadata

  def unpaid_count
    bookings.confirmed.visible.count - bookings.confirmed.visible.paid.count
  end

  def class_not_done
    ( (start_at.present? ? start_at.to_datetime : Date.today()) - Date.today() > -1)
  end

  def expected_revenue
    total = 0
    bookings.confirmed.visible.each do |b|
      total = total + (b.cost.present? ? b.cost : 0)
    end
    return total
  end

  def collected_revenue
    payments.sum(:total)/1.15
  end

  def uncollected_revenue
    expected_revenue - collected_revenue    
  end

  def income
    collected_revenue - ( teacher_payment.present? ? teacher_payment : 0 )
  end

  def attendance
    bookings.confirmed.visible.sum(:guests) + bookings.confirmed.visible.count
  end

  def pay_involved
    (cost.present? ? cost : 0) > 0 
  end

  def todo_attendee_list
    return (start_at > DateTime.now()) && (start_at <= DateTime.tomorrow() + 1) && pay_involved
  end

  def todo_pay_reminder
    return unpaid_count > 0 && pay_involved && ( start_at < DateTime.now() + 3 )
  end

  def todo_payment_summary
    return pay_involved && ( (teacher_cost.present? ? teacher_cost : 0) > 0 ) && ( start_at < DateTime.now() ) && ( start_at > DateTime.now() - 2)
  end

  def meetup_data
    data = read_attribute(:meetup_data)
    if data.present?
      event = JSON.parse(data)
      event["event"]
    else
      {}
    end
  end

  def set_from_meetup_data
    return if meetup_data.empty?
    self.created_at = Time.at(meetup_data["created"] / 1000)
    self.updated_at = Time.at(meetup_data["updated"] / 1000)
    self.start_at = Time.at(meetup_data["time"] / 1000) if meetup_data["time"]
    self.duration = meetup_data["duration"] / 1000 if meetup_data["duration"]
    parts = name.split(":")
    c = Category.find_by_name parts[0]
    if c.present?
      self.category = c
      self.name = parts[1]
    else
      if parts[1]
        c = Category.create(:name => parts[0])
        self.category = c
        self.name = parts[1]
      end
    end
  end

  def set_metadata
    self.visible = true
  end

  def self.create_from_meetup_hash(result, group)
    l = Lesson.find_or_initialize_by_meetup_id result.id
    l.name = result.name
    l.meetup_id = result.id
    l.description = result.description
    l.meetup_data = result.to_json
    l.save
    l.groups << group unless l.groups.exists? group
    l.valid?
  end
end
