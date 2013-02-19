class ChannelLesson < ActiveRecord::Base
  validates_uniqueness_of :lesson_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :lesson
end
