class ChangeLessonsToCoursesInChannelLessons < ActiveRecord::Migration
  def up
    rename_column :channel_lessons, :lesson_id, :course_id
    rename_table :channel_lessons, :channel_courses
  end

  def down
    rename_table :channel_lessons, :channel_courses
    rename_column :channel_lessons, :lesson_id, :course_id
  end
end
