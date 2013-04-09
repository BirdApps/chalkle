class ChannelLessonSuggestion < ActiveRecord::Base
  belongs_to :channel
  belongs_to :lesson_suggestion
end
