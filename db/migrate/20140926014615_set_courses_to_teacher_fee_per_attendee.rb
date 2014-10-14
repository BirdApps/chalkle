class SetCoursesToTeacherFeePerAttendee < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      course.update_column :teacher_pay_type, "Fee per attendee"
    end
  end

  def down
  end
end
