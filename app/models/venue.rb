class Venue < ActiveRecord::Base
  attr_accessible :meetup_id, :name, :address_1, :city, :lat, :lon, :as => :admin

  has_many :cities
  has_many :channels, :through => :cities

  validates_presence_of :name, :address_1, :city
end
