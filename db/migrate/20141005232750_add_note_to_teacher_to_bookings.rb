class AddNoteToTeacherToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :note_to_teacher, :string
  end
end
