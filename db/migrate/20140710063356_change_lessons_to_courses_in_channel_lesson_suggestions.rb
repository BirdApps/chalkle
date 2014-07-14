class ChangeLessonsToCoursesInChannelLessonSuggestions < ActiveRecord::Migration
  def up
    rename_column :channel_lesson_suggestions, :lesson_suggestion_id, :course_suggestion_id
    rename_table :channel_lesson_suggestions, :channel_course_suggestions
    
  end

  def down
    rename_table :channel_course_suggestions, :channel_lesson_suggestions
    rename_column :channel_lesson_suggestions, :lesson_suggestion_id, :course_suggestion_id
  end
end
