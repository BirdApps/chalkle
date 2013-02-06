class AddMaxAttendeeToLesson < ActiveRecord::Migration
  def up
  	add_column :lessons, :max_attendee, :integer, :default => nil

  	Lesson.reset_column_information

    Lesson.all.each { |l| l.update_attribute :max_attendee, nil }
  end

  def down
  	remove_column :lessons, :max_attendee
  end
end
