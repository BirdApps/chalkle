class ChangeLessonsToCoursesInLessonImages < ActiveRecord::Migration
  def up
    rename_column :lesson_images, :lesson_id, :course_id
    rename_table :lesson_images, :course_images
  end

  def down
    rename_table :course_images, :lesson_images
    rename_column :lesson_images, :course_id, :lesson_id
  end
end