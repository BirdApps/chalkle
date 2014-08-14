class ChannelTeacher < ActiveRecord::Base
  attr_accessible :channel, :channel_id, :chalkler, :chalkler_id, :name, :bio, :pseudo_chalkler_email, :can_make_classes

  belongs_to :channel
  belongs_to :chalkler

  validates_uniqueness_of :chalkler_id, :scope => :channel_id
  validates_presence_of :channel
end
