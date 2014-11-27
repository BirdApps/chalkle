class Notification < ActiveRecord::Base
  
  attr_accessible *BASIC_ATTR = [
    :type, :viewed_at, :actioned_at, :target, :href, :message, :image
  ]

  attr_accessible *BASIC_ATTR, :chalkler, :chalkler_id, :as => :admin

  belongs_to :chalkler
  belongs_to :target, polymorphic: true

  validates_presence_of :message
  validates_presence_of :chalkler
  validates_presence_of :type
  validate :type_defined?
  validate :has_link?

  CHALKLE = "chalkle"
  DISCUSSION = "discussion"
  REMINDER = "reminder"
  FOLLOWING = "following"
  FEEDBACK = "feedback"
  TYPES = [CHALKLE, DISCUSSION, REMINDER, FOLLOWING, FEEDBACK ]
  
  def viewed?
    viewed.present?
  end

  def actioned?
    actioned_at.present?
  end

  private
    def has_link?
      target || href
    end

    def type_defined?
      Notification::TYPES.include? type
    end

end