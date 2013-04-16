class ChannelLessonSuggestion < ActiveRecord::Base
  validates_uniqueness_of :lesson_suggestion_id, :scope => :channel_id

  belongs_to :channel
  belongs_to :lesson_suggestion
end
