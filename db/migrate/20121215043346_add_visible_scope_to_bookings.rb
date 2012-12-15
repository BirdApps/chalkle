class AddVisibleScopeToBookings < ActiveRecord::Migration
  def up
    add_column :bookings, :visible, :boolean
  end

  def down
    remove_column :bookings, :visible
  end
end
