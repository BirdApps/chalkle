class SetBookingDefaultStatusToYes < ActiveRecord::Migration
  def up
    change_column :bookings, :status, :string, :default => 'yes'
  end

  def down
    change_column :bookings, :status, :string, :default => ''
  end
end
