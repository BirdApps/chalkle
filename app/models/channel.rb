class Channel < ActiveRecord::Base
  attr_accessible :name, :url_name, :channel_percentage, :teacher_percentage

  validates :name, :presence => true
  validates :url_name, :presence => true
  validates :channel_percentage, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Channel percentage of revenue must be less than 100%"}
  validates :teacher_percentage, :allow_blank => false, :numericality => { :less_than_or_equal_to => 1, :message => "Teacher percentage of revenue must be less than 100%"}

  has_many :channel_admins
  has_many :admin_users, :through => :channel_admins
  has_many :channel_chalklers
  has_many :chalklers, :through => :channel_chalklers
  has_many :channel_lessons
  has_many :lessons, :through => :channel_lessons
  has_many :bookings, :through => :lessons
  has_many :payments, :through => :bookings
  has_many :channel_categories
  has_many :categories, :through => :channel_categories
end
