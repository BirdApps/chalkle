class Venue < ActiveRecord::Base
  attr_accessible :meetup_id, :name, :address_1, :city_id, :lat, :lon, :as => :admin

  belongs_to :city

  validates_presence_of :name, :address_1, :city_id
end
