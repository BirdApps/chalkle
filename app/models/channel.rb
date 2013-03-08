class Channel < ActiveRecord::Base
  attr_accessible :name, :url_name, :email

  validates :name, :presence => true
  validates :email, allow_blank: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

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
