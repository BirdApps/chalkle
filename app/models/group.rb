class Group < ActiveRecord::Base
  attr_accessible :name, :api_key

  validates :name, :presence => true
  validates :api_key, :presence => true
end
