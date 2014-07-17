class RepeatCourse < ActiveRecord::Base
  attr_accessible = :courses
  has_many :courses
end