class CourseNotice < ActiveRecord::Base
  attr_accessible :chalkler, :chalkler_id, :course, :course_id, :body, :visible, :photo

  mount_uploader :photo, CourseNoticeUploader
  
  validates_presence_of :course
  validates_presence_of :body

  belongs_to :chalkler
  belongs_to :course

  has_one :channel, through: :course

  scope :visible, where(visible: true)

  def edited?
    updated_at != created_at
  end

  def by_attendee?
    chalkler.confirmed_courses.include? course
  end

  def by_teacher?
    chalkler.courses_teaching.include? course
  end

  def deleted?
    !visible
  end

end
