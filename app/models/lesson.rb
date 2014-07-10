class Lesson < ActiveRecord::Base
	
  attr_accessible *BASIC_ATTR = [
    :start_at, :duration, :course_id, :cancelled
  ]

  attr_accessible *BASIC_ATTR, :as => :admin

  belongs_to :course

  validates_format_of :duration, with: /^[+]?([1-9][0-9]*(?:[\.][0-9]*)?|0*\.0*[1-9][0-9]*)(?:[eE][+-][0-9]+)?$/

  validate :starts_within_a_century
  
  def starts_within_a_century
    errors.add(:start_at, "is not within a century") unless start_at <= 100.years.from_now && start_at >= 100.years.ago
  end

end