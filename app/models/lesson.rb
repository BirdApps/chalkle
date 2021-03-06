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

  after_save :reset_end_at

  def between_start_and_end
    start_at < DateTime.current && end_at > DateTime.current
  end

  def end_at
    @end_at ||= start_at + duration 
  end

  def reset_end_at
    @end_at = start_at + duration
  end

end