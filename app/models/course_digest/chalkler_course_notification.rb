class CourseDigest::ChalklerCourseNotification < ActiveRecord::Base
  
  attr_accessible :sent_on,:chalkler,:course
  
  belongs_to :chalkler
  belongs_to :course

  validate :is_unique?

  scope :unsent, -> { where(sent_at: nil) }

  private

  def is_unique?
    unless CourseDigest::ChalklerCourseNotification.where(course_id: self.course, chalkler_id: self.chalkler).empty?
      errors.add :chalkler, "Chalkler has already been notification of this course"
    end
  end

end