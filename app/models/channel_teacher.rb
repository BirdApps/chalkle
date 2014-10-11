require 'avatar_uploader'

class ChannelTeacher < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  EMAIL_VALIDATION_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :channel, :channel_id, :chalkler, :chalkler_id, :name, :email, :bio, :pseudo_chalkler_email, :can_make_classes, :tax_number, :account, :avatar, :courses

  belongs_to :channel
  belongs_to :chalkler
  has_many :courses, class_name: "Course", foreign_key: "teacher_id"

  validates_uniqueness_of :chalkler_id, scope: :channel_id, allow_blank:true
  validates_presence_of :channel_id
  validates_presence_of :email, message: 'Email cannot be blank'
  validates :pseudo_chalkler_email, allow_blank: true, format: { with: EMAIL_VALIDATION_REGEX, :message => "That doesn't look like a real email"  }


  before_save :check_name
  after_save :expire_cache!

  def email
    unless chalkler.nil?
      chalkler.email
    else
      pseudo_chalkler_email
    end
  end

  def students
    courses.collect{ |course| course.chalklers }.flatten
  end

  def email=(email)
    self.chalkler = Chalkler.find_by_email email
    self.pseudo_chalkler_email = email unless chalkler.present?
    #TODO: email chalkler or non-chalkler to tell them they are a teacher
  end

  def next_class
    courses.in_future.displayable.order(:start_at).first
  end

  def check_name
    self.name = chalkler.name if self.name.blank?
  end
  
  def expire_cache!
    courses.each do |course|
      course.expire_cache!
    end
  end
end
