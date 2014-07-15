class Lesson < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :start_at, :duration, :course_id, :cancelled
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

  belongs_to :course

  validates_presence_of :start_at
  validates_presence_of :duration

  validate do |lesson|
    errors.add(:duration, "Duration cannot be negative") if lesson.duration && lesson.duration < 0
  end
end