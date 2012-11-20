class RemoveCostFromPayment < ActiveRecord::Migration
  def up
    remove_column :bookings, :cost
  end

  def down
    add_column :bookings, :cost, :decimal, :precision => 8, :scale => 2
  end
end
