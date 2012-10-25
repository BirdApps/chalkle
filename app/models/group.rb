class Group < ActiveRecord::Base
  attr_accessible :name, :api_key

  validates :name, :presence => true
  validates :api_key, :presence => true

  has_many :group_admins
  has_many :admin_users, :through => :group_admins
  has_many :lessons
end
