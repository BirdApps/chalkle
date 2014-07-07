class Course < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :start_at, :duration
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

  belongs_to :course

  validates_presence_of :course
  
  def method_missing(method, *args)
    return course.send(method, *args) if course.respond_to?(method)
    super
  end
end