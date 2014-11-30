class Notification < ActiveRecord::Base

  attr_accessible *BASIC_ATTR = [
    :notification_type, :valid_from, :valid_till, :viewed_at, :actioned_at, :target, :href, :message, :image
  ]

  attr_accessible *BASIC_ATTR, :chalkler, :chalkler_id, :as => :admin

  belongs_to :chalkler
  belongs_to :target, polymorphic: true

  validates_presence_of :message
  validates_presence_of :href
  validates_presence_of :chalkler
  validates_presence_of :notification_type
  validates_presence_of :valid_from
  validate :type_defined?
  validate :has_link?

  scope :visible, lambda{ where("valid_from < ?", DateTime.current).where("valid_till > ? OR valid_till IS NULL", DateTime.current) }
  scope :unactioned, visible.where(actioned_at: nil)
  scope :unseen, visible.where(viewed_at: nil)
  scope :by_date, order(:valid_from).reverse_order
  scope :recent, visible.limit(20).by_date

  CHALKLE = "chalkle"
  DISCUSSION = "discussion"
  REMINDER = "reminder"
  FOLLOWING = "following"
  FEEDBACK = "feedback"
  MESSAGE = "message"
  TYPES = [CHALKLE, DISCUSSION, REMINDER, FOLLOWING, FEEDBACK, MESSAGE ]
  
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

    def type_defined?
      Notification::TYPES.include? notification_type
    end

end