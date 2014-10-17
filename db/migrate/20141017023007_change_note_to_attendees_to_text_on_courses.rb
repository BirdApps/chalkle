class ChangeNoteToAttendeesToTextOnCourses < ActiveRecord::Migration
  def change
    change_column :courses, :note_to_attendees, :text
  end
end
