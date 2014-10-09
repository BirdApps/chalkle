class AddIndexToBookings < ActiveRecord::Migration
  def change
    add_index :bookings, :course_id
    add_index :bookings, :chalkler_id
  end
end
