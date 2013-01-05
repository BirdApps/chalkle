class AddCostOverrideToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :cost_override, :decimal, :default => 0, :precision => 8, :scale => 2
  end

  def down
    remove_column :bookings, :cost_override
  end
end
