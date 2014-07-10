class ChangeLessonsToCoursesInLessonSuggestions < ActiveRecord::Migration
  def up
    rename_table :lesson_suggestions, :course_suggestions
  end

  def down
    rename_table :course_suggestions, :lesson_suggestions
  end
end
