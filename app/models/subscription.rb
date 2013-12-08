class Subscription < ActiveRecord::Base
  set_table_name 'subscriptions'

  validates_uniqueness_of :chalkler_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :chalkler
end
