class ChannelCourseSuggestion < ActiveRecord::Base
  validates_uniqueness_of :channel_id, :scope => :course_suggestion_id

  belongs_to :channel
  belongs_to :course_suggestion
end
