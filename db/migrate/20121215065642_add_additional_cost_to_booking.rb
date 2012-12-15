class AddAdditionalCostToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :additional_cost, :decimal, :default => 0, :precision => 8, :scale => 2
  end
end
