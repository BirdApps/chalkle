class AddMinAttendeeToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :min_attendee, :integer, :default => 1

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :min_attendee, 1 }
  end

  def down
  	remove_column :lessons, :min_attendee
  end
end
