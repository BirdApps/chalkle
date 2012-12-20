class AddAdditionalCostToBooking < ActiveRecord::Migration
  def up
    add_column :bookings, :additional_cost, :decimal, :default => 0, :precision => 8, :scale => 2
  end

  def down
    remove_column :bookings, :additional_cost
  end
end
