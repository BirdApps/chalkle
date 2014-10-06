class AddNoteToAttendeesToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :note_to_attendees, :string
  end
end
