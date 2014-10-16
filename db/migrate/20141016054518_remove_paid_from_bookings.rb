class RemovePaidFromBookings < ActiveRecord::Migration
  def up
    remove_column :bookings, :paid
  end

  def down
    add_column :bookings, :paid, :decimal
  end
end
