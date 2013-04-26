class ChannelLessonSuggestion < ActiveRecord::Base
  validates_uniqueness_of :channel_id, :scope => :lesson_suggestion_id

  belongs_to :channel
  belongs_to :lesson_suggestion
end
