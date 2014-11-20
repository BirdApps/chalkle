class CourseNotice < ActiveRecord::Base
  attr_accessible :chalkler, :chalkler_id, :course, :course_id, :body, :visible, :photo

  mount_uploader :photo, CourseNoticeUploader
  
  validates_presence_of :course

  belongs_to :chalkler
  belongs_to :course

  before_save :check_body_or_photo

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

  private 
    def check_body_or_photo
      if photo.present? && body.blank?
        self.body = ' '
      end
    end

end
