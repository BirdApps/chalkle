class Course < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :lessons, :bookings, :status, :visible, 
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

	has_many  :lessons
  has_many  :bookings
  has_many  :chalklers, through: :bookings
  has_many  :payments, through: :bookings
  has_one :status
  belongs_to :region
  belongs_to :channel
  belongs_to :teacher, class_name: "Chalkler"
  belongs_to :category

	#Lesson statuses
  STATUS_5 = "Processing"
  STATUS_4 = "Approved"
  STATUS_3 = "Unreviewed"
  STATUS_2 = "On-hold"
  STATUS_1 = "Published"
  VALID_STATUSES = [STATUS_1, STATUS_2, STATUS_3, STATUS_4, STATUS_5]



  validates :status, :inclusion => { :in => VALID_STATUSES, :message => "%{value} is not a valid status"}

  scope :hidden, where(visible: false)
  scope :visible, where(visible: true)
  scope :unreviewed, visible.where(status: STATUS_3)
  scope :on_hold, visible.where(status: STATUS_2)
  scope :approved, visible.where(status: STATUS_4)
  scope :processing, where(status: STATUS_5)
  scope :unpublished, visible.where{ status != STATUS_1 }
  scope :published, visible.where(status: STATUS_1)
  scope :only_with_region, lambda {|region| where(region_id: region.id) }
  scope :only_with_channel, lambda {|channel| where(channel_id: channel.id) }

  def self.upcoming(limit = nil)
    return where{(visible == true) & (status == STATUS_1) & (start_at > Time.now.utc)} if limit.nil?
    where{(visible == true) & (status == STATUS_1) & (start_at > Time.now.utc) & (start_at < limit)}
  end

  def published?
    status == STATUS_1
  end

  def valid_statuses
    VALID_STATUSES
  end
end