class RemoveGuestsFromBooking < ActiveRecord::Migration
  def up
    remove_column :bookings, :guests
  end

  def down
    add_column :bookings, :guests, :integer
  end
end
