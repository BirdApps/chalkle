class ChannelCourse < ActiveRecord::Base
  validates_uniqueness_of :course_id, :scope => :channel_id
  belongs_to :channel
  belongs_to :course
end
