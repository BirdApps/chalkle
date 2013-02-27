class ChannelCategory < ActiveRecord::Base
  validates_uniqueness_of :category_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :category
end
