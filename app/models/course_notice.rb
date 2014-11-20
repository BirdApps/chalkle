class CourseNotice < ActiveRecord::Base
  attr_accessible :chalkler, :chalkler_id, :course, :course_id, :body, :visible, :photo

  mount_uploader :photo, CourseNoticeUploader
  
  validates_presence_of :course
  validates_presence_of :body

  has_one :chalkler
  has_one :course

  scope :visible, where(visible: true).order(:created_at)

  def edited?
    updated_at == created_at
  end

end
