class ChangeTeacherIdFromChalklerFKtoChannelTeacherFkOnCourses < ActiveRecord::Migration
  def up
    Course.transaction do
      Course.all.each do |course|
        if !course.teacher_id.nil?
          teacher = ChannelTeacher.where(chalkler_id: course.teacher_id)[0]
          chalkler = Chalkler.find_by_id course.teacher_id
          if teacher.nil? && !chalkler.nil?
            teacher = ChannelTeacher.create channel_id: course.channel_id, chalkler_id: course.teacher_id, name: chalkler.name
          end
          if !teacher.nil?
            course.update_column 'teacher_id', teacher.id
          end
        end
      end
    end
  end

  def down
    Course.transaction do
      Course.all.each do |course|
         course.update_column 'teacher_id', course.teacher.chalkler_id
      end
    end
  end
end