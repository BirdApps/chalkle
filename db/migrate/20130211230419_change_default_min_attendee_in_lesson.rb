class ChangeDefaultMinAttendeeInLesson < ActiveRecord::Migration
  def change
  	change_column :lessons, :min_attendee, :integer, :default => 2

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :min_attendee, 2 }
  end

  def down
  	change_column :lessons, :min_attendee, :integer, :default => 1

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :min_attendee, 1 }
  end
end
