class BetterBookingsDefaults < ActiveRecord::Migration
  def up
    change_column :bookings, :paid, :boolean, :default => false
    change_column :bookings, :visible, :boolean, :default => true
  end

  def down
    change_column :bookings, :paid, :boolean
    change_column :bookings, :visible, :boolean
  end
end
