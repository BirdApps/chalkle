class Lesson < ActiveRecord::Base
  attr_accessible :name, :meetup_id, :category_id, :teacher_id, :title, :status, :cost, :teacher_cost, :venue_cost, :start_at, :duration, :meetup_data, :description, :visible, :teacher_payment

  has_many :group_lessons
  has_many :groups, :through => :group_lessons
  belongs_to :category
  belongs_to :teacher, class_name: "Chalkler"

  has_many :bookings
  has_many :chalklers, :through => :bookings

  validates_uniqueness_of :meetup_id, allow_nil: true
  validates_numericality_of :teacher_payment, allow_nil: true

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)

  before_create :set_from_meetup_data
  before_create :set_metadata

  def unpaid_count
    bookings.confirmed.visible.count - bookings.paid.visible.count
  end

  def cash_collected
    total = 0
    (booking.confirmed.visible).each do |b|
    end
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
