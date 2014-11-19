class CourseNotice < ActiveRecord::Base
  attr_accessible :chalkler, :chalkler_id, :course, :course_id, :body
  
  validates_presence_of :course
  validates_presence_of :body

  has_one :chalkler
  has_one :course
end
