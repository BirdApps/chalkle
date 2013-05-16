class City < ActiveRecord::Base
  attr_accessible :name, :as => :admin

  has_many :venues

  validates_presence_of :name
end
