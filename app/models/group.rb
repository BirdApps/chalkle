class Group < ActiveRecord::Base
  attr_accessible :name, :api_key

  validates :name, :presence => true
  validates :api_key, :presence => true

  has_many :group_admins
  has_many :admin_users, :through => :group_admins
  has_many :group_chalklers
  has_many :chalklers, :through => :group_chalklers
  has_many :lessons
  has_many :bookings, :through => :lessons
end
