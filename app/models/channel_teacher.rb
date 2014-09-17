class ChannelTeacher < ActiveRecord::Base
  attr_accessible :channel, :channel_id, :chalkler, :chalkler_id, :name, :bio, :pseudo_chalkler_email, :can_make_classes, :tax_number, :account

  belongs_to :channel
  belongs_to :chalkler

  validates_uniqueness_of :chalkler_id, :scope => :channel_id
  validates_presence_of :channel

  def email
    unless chalkler.nil?
      chalkler.email
    else
      pseudo_chalkler_email
    end
  end
end
