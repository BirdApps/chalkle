class Subscription < ActiveRecord::Base
  attr_accessible :chalkler_id, :channel_id
  validates_uniqueness_of :chalkler_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :chalkler
end
