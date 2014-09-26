class SetCoursesToTeacherFeePerAttendee < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      course.update_attribute :teacher_pay_type, "Fee per attendee"
    end
  end

  def down
  end
end
