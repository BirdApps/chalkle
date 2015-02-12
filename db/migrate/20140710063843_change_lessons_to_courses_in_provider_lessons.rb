class ChangeLessonsToCoursesInProviderLessons < ActiveRecord::Migration
  def up
    rename_column :provider_lessons, :lesson_id, :course_id
    rename_table :provider_lessons, :provider_courses
  end

  def down
    rename_table :provider_lessons, :provider_courses
    rename_column :provider_lessons, :lesson_id, :course_id
  end
end
