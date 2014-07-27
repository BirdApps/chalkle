class Lesson < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :start_at, :duration, :course_id, :cancelled
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

  belongs_to :course

  validates_presence_of :start_at
  validates_presence_of :duration
  validates :duration, :allow_blank => false, :numericality => { :greater_than_or_equal_to => 1, :message => "The lesson must have a duration"}
   

  validate do |lesson|
    errors.add(:duration, "Duration cannot be negative") if lesson.duration && lesson.duration < 0
  end
end