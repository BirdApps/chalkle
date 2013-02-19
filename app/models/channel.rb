class Group < ActiveRecord::Base
  attr_accessible :name, :url_name

  validates :name, :presence => true
  validates :url_name, :presence => true

  has_many :group_admins
  has_many :admin_users, :through => :group_admins
  has_many :group_chalklers
  has_many :chalklers, :through => :group_chalklers
  has_many :group_lessons
  has_many :lessons, :through => :group_lessons
  has_many :bookings, :through => :lessons
  has_many :payments, :through => :bookings
  has_many :group_categories
  has_many :categories, :through => :group_categories
end
