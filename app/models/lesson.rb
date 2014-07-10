class Lesson < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :start_at, :duration, :course_id
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

  belongs_to :course

  validates_presence_of :course
  
end