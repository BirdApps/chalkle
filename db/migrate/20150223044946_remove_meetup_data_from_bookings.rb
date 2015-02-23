class RemoveMeetupDataFromBookings < ActiveRecord::Migration
  def up
    remove_column :bookings, :meetup_id
    remove_column :bookings, :meetup_data
    remove_column :providers, :meetup_url
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
