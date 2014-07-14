class RenameIndexChannelLessonsOnChannelIdAndLessonIdOnChannelCourses < ActiveRecord::Migration
  def up
    rename_index :channel_courses, 'index_channel_lessons_on_channel_id_and_lesson_id', 'index_channel_courses_on_channel_id_and_course_id'
  end

  def down
    rename_index :channel_courses, 'index_channel_courses_on_channel_id_and_course_id', 'index_channel_lessons_on_channel_id_and_lesson_id'
  end
end
