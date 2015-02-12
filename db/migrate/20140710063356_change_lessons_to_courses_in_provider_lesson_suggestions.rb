class ChangeLessonsToCoursesInProviderLessonSuggestions < ActiveRecord::Migration
  def up
    rename_column :provider_lesson_suggestions, :lesson_suggestion_id, :course_suggestion_id
    rename_table :provider_lesson_suggestions, :provider_course_suggestions
    
  end

  def down
    rename_table :provider_course_suggestions, :provider_lesson_suggestions
    rename_column :provider_lesson_suggestions, :lesson_suggestion_id, :course_suggestion_id
  end
end
