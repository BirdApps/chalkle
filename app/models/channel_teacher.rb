require 'avatar_uploader'

class ChannelTeacher < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  attr_accessible :channel, :channel_id, :chalkler, :chalkler_id, :name, :bio, :pseudo_chalkler_email, :can_make_classes, :tax_number, :account, :avatar, :courses

  belongs_to :channel
  belongs_to :chalkler
  has_many :courses, class_name: "Course", foreign_key: "teacher_id"

  validates_uniqueness_of :chalkler_id, :scope => :channel_id
  validates_presence_of :channel_id
  validates_presence_of :email


  def email
    unless chalkler.nil?
      chalkler.email
    else
      pseudo_chalkler_email
    end
  end

  def email=(value)
    pseudo_chalkler_email = value
  end

  def next_class
    courses.in_future.displayable.order(:start_at).first
  end
end
