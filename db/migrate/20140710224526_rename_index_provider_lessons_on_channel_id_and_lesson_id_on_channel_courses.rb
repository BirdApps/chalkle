class RenameIndexProviderLessonsOnProviderIdAndLessonIdOnProviderCourses < ActiveRecord::Migration
  def up
    rename_index :provider_courses, 'index_provider_lessons_on_provider_id_and_lesson_id', 'index_provider_courses_on_provider_id_and_course_id'
  end

  def down
    rename_index :provider_courses, 'index_provider_courses_on_provider_id_and_course_id', 'index_provider_lessons_on_provider_id_and_lesson_id'
  end
end
