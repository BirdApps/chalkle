class ChangeBookingsLessonId < ActiveRecord::Migration
  def up
    rename_column :bookings, :lesson_id, :course_id
  end

  def down
    rename_column :bookings, :course_id, :lesson_id
  end
end
