class ChangeStringsToTextOnCourses < ActiveRecord::Migration
  def up
    change_column :courses, :venue_address, :text
    change_column :courses, :note_to_attendees, :text
    change_column :courses, :cancelled_reason, :text
  end

  def down
    change_column :courses, :venue_address, :string
    change_column :courses, :note_to_attendees, :string
    change_column :courses, :cancelled_reason, :string
  end
end
