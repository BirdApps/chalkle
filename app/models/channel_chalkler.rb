class ChannelChalkler < ActiveRecord::Base
  validates_uniqueness_of :chalkler_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :chalkler
end
