class ChannelAdmin < ActiveRecord::Base
  validates_uniqueness_of :admin_user_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :admin_user
end
