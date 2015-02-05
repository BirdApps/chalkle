class AddInviteChalklerToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :invite_chalkler, :boolean
  end
end
