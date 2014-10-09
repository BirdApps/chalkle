class ChannelAdmin < ActiveRecord::Base
  attr_accessible :chalkler, :chalkler_id, :channel, :channel_id, :admin_user, :admin_user_id

  validates_uniqueness_of :admin_user_id, :scope => :channel_id, allow_blank: true
  validates_presence_of :chalkler_id
  
  has_many :courses, :through => :channel

  belongs_to :channel
  belongs_to :admin_user
  belongs_to :chalkler
end
