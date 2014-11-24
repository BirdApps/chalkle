class RepeatCourse < ActiveRecord::Base
  attr_accessible :courses
  has_many :courses
  has_many :interaction, as: :actor 
  has_many :interaction, as: :target
end