class AddChalklerDeletedToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :chalkler_deleted, :boolean, default: false
  end
end
