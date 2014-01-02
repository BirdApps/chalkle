class ChannelRegion < ActiveRecord::Base
  belongs_to :channel
  belongs_to :region
end