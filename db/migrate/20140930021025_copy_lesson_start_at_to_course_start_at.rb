class CopyLessonStartAtToCourseStartAt < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      unless course.start_at.present?
        unless course.lessons.empty?
          course.start_at = course.first_lesson.start_at
        else
          course.start_at = DateTime.now
        end
        puts course.id
        course.save
      end
    end
  end

  def down
  end
end
