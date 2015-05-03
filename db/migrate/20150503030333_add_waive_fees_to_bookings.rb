class AddWaiveFeesToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :waive_fees, :boolean, null: false, default: false
  end
end
