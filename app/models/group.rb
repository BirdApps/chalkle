class Group < ActiveRecord::Base
  attr_accessible :name, :url_name, :api_key

  validates :name, :presence => true
  validates :url_name, :presence => true
  validates :api_key, :presence => true

  has_many :group_admins
  has_many :admin_users, :through => :group_admins
  has_many :group_chalklers
  has_many :chalklers, :through => :group_chalklers
  has_many :group_lessons
  has_many :lessons, :through => :group_lessons
  has_many :group_categories
  has_many :categories, :through => :group_categories
  has_many :bookings, :through => :lessons
end
