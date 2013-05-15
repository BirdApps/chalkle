class City < ActiveRecord::Base
  attr_accessible :name, :as => :admin

  has_many :cities_channels
  has_many :channels, :through => :cities_channels
  has_many :venues

  validates_presence_of :name
end
