class ProviderContact < ActiveRecord::Base
  attr_accessible :provider, :chalkler, :from, :to, :subject, :message,:status

  belongs_to  :provider
  belongs_to  :chalkler

  validates_presence_of :provider
  validates_presence_of :from
  validates_presence_of :subject
  validates_presence_of :message

  STATUS_1 = "Unread"
  STATUS_2 = "Read"
  STATUS_3 = "Archived"

  before_validation :set_defaults
  after_create :send_email!

  def set_defaults
    self.to = provider.email if provider.present? && to.blank?
    self.to = provider.provider_admins.first.email if provider.provider_admins.first.present? && to.blank?
    self.status = STATUS_1 if status.blank?
    self.from = chalkler.email if chalkler.present?
    true
  end
  
private

  def send_email!
    ProviderMailer.delay.contact(self) unless to.blank?
  end
end
