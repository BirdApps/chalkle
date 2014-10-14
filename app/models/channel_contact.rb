class ChannelContact < ActiveRecord::Base
  attr_accessible :channel, :chalkler, :from, :to, :subject, :message,:status

  belongs_to :channel
  has_one :chalkler

  validates_presence_of :channel
  validates_presence_of :from
  validates_presence_of :subject
  validates_presence_of :message

  STATUS_1 = "Unread"
  STATUS_2 = "Read"
  STATUS_3 = "Archived"

  before_validation :set_defaults
  after_create :send_email!

  def set_defaults
    self.to = channel.email if channel.present? && to.blank?
    self.to = channel.channel_admins.first.email if channel.channel_admins.first.present? && to.blank?
    self.status = STATUS_1 if status.blank?
    self.from = chalkler.email if chalkler.present?
    true
  end

  def send_email!
    ChannelMailer.contact(self).deliver! unless to.blank?
  end
end
