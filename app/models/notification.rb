class Notification < ActiveRecord::Base

  attr_accessible *BASIC_ATTR = [
    :notification_type, :valid_from, :valid_till, :viewed_at, :actioned_at, :target, :href, :message, :image
  ]

  attr_accessible *BASIC_ATTR, :chalkler, :chalkler_id, :as => :admin

  belongs_to :chalkler
  belongs_to :target, polymorphic: true

  validates_presence_of :message
  validates_presence_of :chalkler
  validates_presence_of :notification_type
  validates_presence_of :valid_from
  validate :type_defined?
  validate :has_link?

  scope :visible, where("valid_from < ?", DateTime.current).where("valid_till > ? OR valid_till IS NULL", DateTime.current) 
  scope :unactioned, where(actioned_at: nil)
  scope :unseen, where(viewed_at: nil)

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

  def visible?
    (valid_from < DateTime.current ) && ( valid_till == nil|| valid_till > DateTime.current)
  end

  private
    def has_link?
      target || href
    end

    def type_defined?
      Notification::TYPES.include? notification_type
    end

end