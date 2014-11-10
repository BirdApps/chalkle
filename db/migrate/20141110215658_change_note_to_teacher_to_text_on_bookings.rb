class ChangeNoteToTeacherToTextOnBookings < ActiveRecord::Migration
  def change
    change_column :bookings, :note_to_teacher, :text
  end
end
