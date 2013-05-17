class ChangeDefaultGuests < ActiveRecord::Migration
  def change
  	change_column :bookings, :guests, :integer, :default => 0
  end

end
