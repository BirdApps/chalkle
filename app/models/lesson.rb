class Course < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :start_at, :duration
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

  belongs_to :course

  validates_presence_of :course
  
end