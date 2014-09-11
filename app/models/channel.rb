require 'channel_logo_uploader'

class Channel < ActiveRecord::Base
  mount_uploader :logo, ChannelLogoUploader
  mount_uploader :hero, ChannelHeroUploader

  attr_accessible *BASIC_ATTR = [:name,:channel_plan, :plan_name, :plan_max_admin_logins, :plan_class_attendee_cost, :plan_course_attendee_cost, :plan_max_free_class_attendees, :plan_annual_cost, :plan_processing_fee]

  attr_accessible *BASIC_ATTR, :channel_teachers, :url_name, :region_ids, :regions, :channel_rate_override, :teacher_percentage, :email, :account, :visible, :short_description, :description, :website_url, :logo, :photos_attributes, :hero, :as => :admin

  validates_presence_of :name
   validates_presence_of :channel_plan
  validates :channel_rate_override, numericality: true, allow_blank: true
  validates :teacher_percentage, presence: true, numericality: {less_than_or_equal_to: 1, message: "Teacher percentage of revenue must be less than or equal to 1"}
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates_format_of :account, allow_blank: true, with: /^\d{2}\-\d{4}\-\d{7}\-\d{2,3}$/, message: "Account number should be in format of xx-xxxx-xxxxxxx-suffix"
  validates_uniqueness_of :name, allow_blank: true
  validates_uniqueness_of :url_name, allow_blank: true
  validates :short_description, length: { maximum: 250 }

  has_many :channel_admins
  has_many :admin_users, through: :channel_admins
  has_many :subscriptions
  has_many :chalklers, through: :subscriptions, source: :chalkler
  has_many :courses
  has_many :bookings, through: :courses
  has_many :payments, through: :bookings
  has_many :channel_categories
  has_many :categories, through: :channel_categories
  has_many :photos, class_name: 'ChannelPhoto', dependent: :destroy
  has_many :channel_regions, dependent: :destroy
  has_many :regions, through: :channel_regions
  has_many :channel_teachers
  
  belongs_to :channel_plan

  accepts_nested_attributes_for :photos

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :has_logo, where("logo IS NOT NULL")
  scope :has_hero, where("hero IS NOT NULL")
  scope :chalkler_can_teach, lambda { |chalkler| joins(:channel_teachers).where("chalkler_id = ?", chalkler.id) }

  def self.select_options(channel)
    channel.map { |c| [c.name, c.id] }
  end

  def self.with_displable_classes_in_future
    channels = []
    Channel.all.each do |channel|
      channels << channel if channel.courses.in_future.displayable.count > 0
    end
    channels
  end

  def fee
    channel_rate_override
  end

  def remaining_free_class_attendees
    #TODO work out the remaining
    2
  end

  #Channel performances
  def channel_stats(start, period)
    ChannelStats.new(start, period, self)
  end

  def path
    url_name
  end

  def financial_table(first_day, period, num_rows)
    financials = StatsMath.new()
    num_rows.times do |i|
      financials[i] = channel_stats(first_day + i*period, period).financial_stats
    end
    financials
  end

  def courses_table(first_day, period, num_rows)
    courses = StatsMath.new()
    num_rows.times do |i|
      courses[i] = channel_stats(first_day + i*period, period).course_stats
    end
    courses
  end

  def chalkler_table(first_day, period, num_rows)
    chalkler = StatsMath.new()
    num_rows.times do |i|
      chalkler[i] = channel_stats(first_day + i*period, period).chalkler_stats
    end
    chalkler
  end

  #Properties of Channels
  def new_chalklers(start_date, end_date)
    chalklers.where{(created_at.gt start_date.utc) & (created_at.lteq end_date.utc)}
  end

  def all_chalklers(date)
    chalklers.where{created_at.lteq date.utc}
  end

  def course_announced(start_date,end_date)
    courses.published.start_at_between(start_date,end_date)
  end

  def course_ran(start_date,end_date)
    courses.visible.published.start_at_between(start_date,end_date)
  end

  def cancel_courses(start_date,end_date)
    courses.hidden.start_at_between(start_date,end_date)
  end

  def past_courses(date)
    courses.visible.published.previous
  end

  def paid_courses(start_date,end_date)
    course_ran(start_date,end_date).paid
  end

  def cost_calculator
    if channel_plan.nil?
      ChannelPlan.default.cost_calculator self
    else
      channel_plan.clone.apply_custom(self).cost_calculator
    end
  end

  def plan
    plan = channel_plan.clone

  end

  def region_names
    regions.map(&:name)
  end

  def country_name
    'New Zealand'
  end

  after_create :set_url_name
  def set_url_name
    url_name = name.parameterize
    self.url_name = Channel.find_by_url_name(url_name).nil? ? url_name : url_name+self.id.to_s
    save
  end

end
