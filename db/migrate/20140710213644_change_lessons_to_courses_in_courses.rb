class ChangeLessonsToCoursesInCourses < ActiveRecord::Migration
  def up
    rename_column :courses, :lesson_type, :course_type
    rename_column :courses, :lesson_skill, :course_skill
    rename_column :courses, :lesson_upload_image, :course_upload_image
  end

  def down
     rename_column :courses, :course_type, :lesson_type
    rename_column :courses, :course_skill, :lesson_skill
    rename_column :courses, :course_upload_image, :lesson_upload_image
  end
end
